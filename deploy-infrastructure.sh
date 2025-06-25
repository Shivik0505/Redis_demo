#!/bin/bash

set -e

echo "=== Redis Infrastructure Deployment ==="

# Step 1: Create key pair if it doesn't exist
echo "Step 1: Checking/Creating key pair..."
if ! aws ec2 describe-key-pairs --key-names my-key-aws --region ap-south-1 >/dev/null 2>&1; then
    echo "Creating key pair 'my-key-aws'..."
    aws ec2 create-key-pair --key-name my-key-aws --region ap-south-1 --query 'KeyMaterial' --output text > my-key-aws.pem
    chmod 400 my-key-aws.pem
    echo "Key pair created successfully!"
else
    echo "Key pair 'my-key-aws' already exists."
fi

# Step 2: Clean up any conflicting resources
echo "Step 2: Cleaning up conflicting resources..."
./cleanup-conflicts.sh

# Step 3: Initialize Terraform
echo "Step 3: Initializing Terraform..."
cd terraform
terraform init

# Step 4: Plan the deployment
echo "Step 4: Planning Terraform deployment..."
terraform plan -out=tfplan

# Step 5: Apply the deployment
echo "Step 5: Applying Terraform deployment..."
terraform apply tfplan

echo "=== Deployment completed successfully! ==="
echo "Your Redis infrastructure is now ready."
echo ""
echo "To connect to your instances:"
echo "1. Public instance: ssh -i ../my-key-aws.pem ubuntu@<public-ip>"
echo "2. Private instances: ssh -i ../my-key-aws.pem ubuntu@<private-ip> (via bastion)"
echo ""
echo "Run 'terraform output' to see all resource details."
