#!/bin/bash

# Create the key pair in ap-south-1 region
aws ec2 create-key-pair --key-name my-key-aws --region ap-south-1 --query 'KeyMaterial' --output text > my-key-aws.pem

# Set proper permissions
chmod 400 my-key-aws.pem

echo "Key pair 'my-key-aws' created successfully!"
echo "Private key saved as my-key-aws.pem"
