#!/bin/bash

echo "=== Quick AWS Resource Cleanup ==="
echo "This will automatically clean up unused resources"

# Release unassociated Elastic IPs
echo "Releasing unassociated Elastic IPs..."
aws ec2 describe-addresses --region ap-south-1 --query 'Addresses[?AssociationId==null].AllocationId' --output text | while read alloc_id; do
    if [ ! -z "$alloc_id" ]; then
        echo "Releasing Elastic IP: $alloc_id"
        aws ec2 release-address --region ap-south-1 --allocation-id $alloc_id
    fi
done

# Delete unused VPCs (non-default with no instances)
echo "Cleaning up unused VPCs..."
aws ec2 describe-vpcs --region ap-south-1 --filters "Name=is-default,Values=false" --query 'Vpcs[].VpcId' --output text | while read vpc_id; do
    if [ ! -z "$vpc_id" ]; then
        instance_count=$(aws ec2 describe-instances --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text | wc -w)
        if [ $instance_count -eq 0 ]; then
            echo "Cleaning up VPC: $vpc_id"
            
            # Delete NAT Gateways first
            aws ec2 describe-nat-gateways --region ap-south-1 --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[].NatGatewayId' --output text | while read nat_id; do
                [ ! -z "$nat_id" ] && aws ec2 delete-nat-gateway --region ap-south-1 --nat-gateway-id $nat_id
            done
            
            # Wait a bit for NAT gateways to delete
            sleep 10
            
            # Delete subnets
            aws ec2 describe-subnets --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].SubnetId' --output text | while read subnet_id; do
                [ ! -z "$subnet_id" ] && aws ec2 delete-subnet --region ap-south-1 --subnet-id $subnet_id 2>/dev/null
            done
            
            # Detach and delete internet gateways
            aws ec2 describe-internet-gateways --region ap-south-1 --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[].InternetGatewayId' --output text | while read igw_id; do
                if [ ! -z "$igw_id" ]; then
                    aws ec2 detach-internet-gateway --region ap-south-1 --internet-gateway-id $igw_id --vpc-id $vpc_id 2>/dev/null
                    aws ec2 delete-internet-gateway --region ap-south-1 --internet-gateway-id $igw_id 2>/dev/null
                fi
            done
            
            # Delete route tables (except main)
            aws ec2 describe-route-tables --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text | while read rt_id; do
                [ ! -z "$rt_id" ] && aws ec2 delete-route-table --region ap-south-1 --route-table-id $rt_id 2>/dev/null
            done
            
            # Delete security groups (except default)
            aws ec2 describe-security-groups --region ap-south-1 --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text | while read sg_id; do
                [ ! -z "$sg_id" ] && aws ec2 delete-security-group --region ap-south-1 --group-id $sg_id 2>/dev/null
            done
            
            # Finally delete the VPC
            aws ec2 delete-vpc --region ap-south-1 --vpc-id $vpc_id 2>/dev/null && echo "Deleted VPC: $vpc_id"
        fi
    fi
done

echo "Cleanup completed!"
echo "You can now retry your Terraform deployment."
