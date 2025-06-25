#!/bin/bash

echo "=== AWS Resource Cleanup Script ==="
echo "This will help you identify and clean up unused AWS resources"
echo ""

# Check VPC usage
echo "=== Current VPC Usage ==="
aws ec2 describe-vpcs --region ap-south-1 --query 'Vpcs[].{VpcId:VpcId,State:State,CidrBlock:CidrBlock,IsDefault:IsDefault,Tags:Tags[?Key==`Name`].Value|[0]}' --output table

echo ""
echo "=== Current Elastic IP Usage ==="
aws ec2 describe-addresses --region ap-south-1 --query 'Addresses[].{AllocationId:AllocationId,PublicIp:PublicIp,AssociationId:AssociationId,InstanceId:InstanceId}' --output table

echo ""
echo "=== Cleanup Options ==="
echo "1. Delete unused VPCs (non-default, no instances)"
echo "2. Release unassociated Elastic IPs"
echo "3. Show detailed resource usage"
echo ""

read -p "Choose option (1/2/3) or 'q' to quit: " choice

case $choice in
    1)
        echo "=== Finding unused VPCs ==="
        aws ec2 describe-vpcs --region ap-south-1 --filters "Name=is-default,Values=false" --query 'Vpcs[].VpcId' --output text | while read vpc_id; do
            if [ ! -z "$vpc_id" ]; then
                instance_count=$(aws ec2 describe-instances --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text | wc -w)
                if [ $instance_count -eq 0 ]; then
                    echo "VPC $vpc_id has no instances. Safe to delete."
                    read -p "Delete VPC $vpc_id? (y/n): " confirm
                    if [ "$confirm" = "y" ]; then
                        # Delete VPC dependencies first
                        aws ec2 describe-subnets --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].SubnetId' --output text | while read subnet_id; do
                            [ ! -z "$subnet_id" ] && aws ec2 delete-subnet --region ap-south-1 --subnet-id $subnet_id
                        done
                        
                        aws ec2 describe-internet-gateways --region ap-south-1 --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[].InternetGatewayId' --output text | while read igw_id; do
                            [ ! -z "$igw_id" ] && aws ec2 detach-internet-gateway --region ap-south-1 --internet-gateway-id $igw_id --vpc-id $vpc_id
                            [ ! -z "$igw_id" ] && aws ec2 delete-internet-gateway --region ap-south-1 --internet-gateway-id $igw_id
                        done
                        
                        aws ec2 delete-vpc --region ap-south-1 --vpc-id $vpc_id
                        echo "Deleted VPC $vpc_id"
                    fi
                else
                    echo "VPC $vpc_id has $instance_count instances. Skipping."
                fi
            fi
        done
        ;;
    2)
        echo "=== Finding unassociated Elastic IPs ==="
        aws ec2 describe-addresses --region ap-south-1 --query 'Addresses[?AssociationId==null].{AllocationId:AllocationId,PublicIp:PublicIp}' --output table
        aws ec2 describe-addresses --region ap-south-1 --query 'Addresses[?AssociationId==null].AllocationId' --output text | while read alloc_id; do
            if [ ! -z "$alloc_id" ]; then
                read -p "Release Elastic IP $alloc_id? (y/n): " confirm
                if [ "$confirm" = "y" ]; then
                    aws ec2 release-address --region ap-south-1 --allocation-id $alloc_id
                    echo "Released Elastic IP $alloc_id"
                fi
            fi
        done
        ;;
    3)
        echo "=== Detailed Resource Usage ==="
        echo "VPCs:"
        aws ec2 describe-vpcs --region ap-south-1 --output table
        echo ""
        echo "Elastic IPs:"
        aws ec2 describe-addresses --region ap-south-1 --output table
        echo ""
        echo "NAT Gateways:"
        aws ec2 describe-nat-gateways --region ap-south-1 --output table
        ;;
    *)
        echo "Exiting..."
        ;;
esac
