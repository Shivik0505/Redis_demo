#!/bin/bash

echo "Cleaning up conflicting resources..."

# Remove existing security groups with the same name
echo "Checking for existing security groups..."
aws ec2 describe-security-groups --region ap-south-1 --filters "Name=group-name,Values=default-vpc-sg" --query 'SecurityGroups[].GroupId' --output text | while read sg_id; do
    if [ ! -z "$sg_id" ]; then
        echo "Deleting security group: $sg_id"
        aws ec2 delete-security-group --group-id "$sg_id" --region ap-south-1 2>/dev/null || echo "Could not delete $sg_id (may be in use)"
    fi
done

# Check for existing routes that might conflict
echo "Checking for conflicting routes..."
aws ec2 describe-route-tables --region ap-south-1 --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --region ap-south-1 --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)" --query 'RouteTables[].Routes[?DestinationCidrBlock==`10.0.0.0/16`]' --output table

echo "Cleanup completed. You may need to manually remove some resources if they're still in use."
