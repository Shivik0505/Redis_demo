# Alternative configuration to use existing VPC and avoid EIP limits
# Replace the VPC module with this if you want to use default VPC

# Use existing default VPC
data "aws_vpc" "existing" {
  default = true
}

# Use existing subnets
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

data "aws_subnet" "existing_subnet" {
  id = data.aws_subnets.existing.ids[0]
}

# Alternative: Use existing internet gateway instead of NAT
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Instructions:
# 1. Comment out the VPC module in main.tf
# 2. Comment out the subnet module in main.tf  
# 3. Update instance module to use data.aws_subnet.existing_subnet.id
# 4. This will deploy instances in your default VPC without creating new resources
