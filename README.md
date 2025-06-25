[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shivik0505/Redis_demo)


# Redis Infrastructure Deployment - End-to-End Guide

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment Methods](#deployment-methods)
- [Troubleshooting](#troubleshooting)
- [Infrastructure Details](#infrastructure-details)
- [Post-Deployment](#post-deployment)
- [Cleanup](#cleanup)

## 🎯 Overview

This project deploys a complete Redis infrastructure on AWS using Infrastructure as Code (IaC) with Terraform and configuration management with Ansible. The setup includes:

- **Custom VPC** with public and private subnets across multiple AZs
- **4 EC2 instances**: 1 bastion host + 3 Redis nodes for clustering
- **Security groups** with proper Redis port configurations
- **NAT Gateway** for private subnet internet access
- **VPC Peering** for cross-VPC communication
- **Automated deployment** via Jenkins CI/CD pipeline

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Custom VPC (10.0.0.0/16)               │
├─────────────────────────────────────────────────────────────┤
│  Public Subnet (10.0.1.0/24)                              │
│  ┌─────────────────┐                                       │
│  │  Bastion Host   │ ← SSH Access                          │
│  │  (Public IP)    │                                       │
│  └─────────────────┘                                       │
├─────────────────────────────────────────────────────────────┤
│  Private Subnets                                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │ Redis Node 1    │ │ Redis Node 2    │ │ Redis Node 3    ││
│  │ (10.0.2.0/24)   │ │ (10.0.3.0/24)   │ │ (10.0.4.0/24)   ││
│  │ ap-south-1a     │ │ ap-south-1b     │ │ ap-south-1c     ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Prerequisites

### Required Tools
- **AWS CLI** (configured with credentials)
- **Terraform** (>= 1.0)
- **Ansible** (>= 2.9)
- **Git**
- **Jenkins** (for CI/CD deployment)

### AWS Requirements
- AWS Account with appropriate permissions
- AWS CLI configured with access keys
- Sufficient service limits:
  - VPCs: At least 1 available
  - Elastic IPs: At least 1 available
  - EC2 instances: At least 4 t3.micro instances

### Jenkins Setup (for CI/CD)
- Jenkins server with required plugins:
  - Git plugin
  - AWS CLI plugin
  - Ansible plugin
- AWS credentials configured in Jenkins:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## 🚀 Quick Start

### Method 1: Automated Deployment (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JayLikhare316/redisdemo.git
   cd redisdemo
   ```

2. **Run the automated deployment script:**
   ```bash
   ./deploy-infrastructure.sh
   ```

### Method 2: Jenkins CI/CD Pipeline

1. **Set up Jenkins job:**
   - Create new Pipeline job
   - Configure SCM: `https://github.com/JayLikhare316/redisdemo.git`
   - Enable SCM polling: `H/5 * * * *` (every 5 minutes)

2. **Configure Jenkins credentials:**
   - Add AWS credentials with IDs: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

3. **Run the pipeline:**
   - Choose parameters: `action=apply`, `autoApprove=true`
   - Pipeline will automatically handle key pair creation and deployment

## ⚙️ Configuration

### Key Configuration Files

#### 1. Terraform Variables (`terraform/instances/variable.tf`)
```hcl
variable "key-name" {
  type = string
  default = "my-key-aws"  # ← Change this to your preferred key name
}

variable "instance-type" {
  type = string
  default = "t3.micro"    # ← Change for different instance sizes
}

variable "ami-id" {
  type = string
  default = "ami-09b0a86a2c84101e1"  # ← Ubuntu 22.04 LTS (ap-south-1)
}
```

#### 2. AWS Region Configuration (`terraform/provider.tf`)
```hcl
provider "aws" {
  region = "ap-south-1"  # ← Change to your preferred region
}
```

#### 3. VPC Configuration (`terraform/vpc/main.tf`)
```hcl
resource "aws_vpc" "redis-VPC" {
  cidr_block = "10.0.0.0/16"  # ← Modify CIDR if needed
  # ... other configurations
}
```

### Required Changes for Different Environments

#### For Different AWS Regions:
1. Update `provider.tf` with your region
2. Update AMI ID in `terraform/instances/variable.tf` for your region
3. Update availability zones in subnet configurations

#### For Different Instance Types:
1. Modify `instance-type` in `terraform/instances/variable.tf`
2. Ensure your AWS account has limits for the chosen instance type

#### For Different Network Configuration:
1. Update CIDR blocks in VPC and subnet configurations
2. Modify security group rules if needed
3. Update route table configurations

## 🚀 Deployment Methods

### Method 1: Manual Terraform Deployment

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Create execution plan
terraform plan -out=tfplan

# 3. Apply the plan
terraform apply tfplan

# 4. Run Ansible configuration
cd ..
ansible-playbook -i aws_ec2.yaml playbook.yml --private-key=my-key-aws.pem
```

### Method 2: Using Deployment Script

```bash
# Single command deployment
./deploy-infrastructure.sh
```

### Method 3: Jenkins Pipeline

1. **Trigger via SCM polling** (automatic on git push)
2. **Manual trigger** with parameters:
   - `action`: `apply` or `destroy`
   - `autoApprove`: `true` or `false`

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. AWS Service Limits Exceeded
**Error:** `VpcLimitExceeded` or `AddressLimitExceeded`

**Solution:**
```bash
# Run cleanup script to free resources
./quick-cleanup.sh

# Or interactive cleanup
./cleanup-aws-resources.sh
```

#### 2. Key Pair Not Found
**Error:** `InvalidKeyPair.NotFound`

**Solution:** The deployment automatically creates the key pair. If manual creation is needed:
```bash
aws ec2 create-key-pair --key-name my-key-aws --region ap-south-1 --query 'KeyMaterial' --output text > my-key-aws.pem
chmod 400 my-key-aws.pem
```

#### 3. Security Group Conflicts
**Error:** `InvalidGroup.Duplicate`

**Solution:** The configuration uses random suffixes to avoid conflicts. If issues persist:
```bash
# Clean up conflicting security groups
aws ec2 describe-security-groups --region ap-south-1 --filters "Name=group-name,Values=default-vpc-sg*" --query 'SecurityGroups[].GroupId' --output text | xargs -I {} aws ec2 delete-security-group --group-id {}
```

#### 4. Route Already Exists
**Error:** `RouteAlreadyExists`

**Solution:** The VPC peering route creation is commented out to avoid conflicts. VPC peering still works for connectivity.

### Debug Commands

```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify Terraform state
terraform show

# Check deployed resources
terraform output

# Validate Ansible inventory
ansible-inventory -i aws_ec2.yaml --list
```

## 🏗️ Infrastructure Details

### Created Resources

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| VPC | 1 | Custom network environment |
| Subnets | 4 | 1 public, 3 private across AZs |
| EC2 Instances | 4 | 1 bastion + 3 Redis nodes |
| Security Groups | 3 | Network access control |
| NAT Gateway | 1 | Internet access for private subnets |
| Internet Gateway | 1 | Internet access for public subnet |
| Elastic IP | 1 | Static IP for NAT Gateway |
| Route Tables | 2 | Network routing configuration |
| VPC Peering | 1 | Cross-VPC communication |

### Security Configuration

#### Public Security Group (Bastion)
- **SSH (22)**: 0.0.0.0/0
- **HTTP (80)**: 0.0.0.0/0
- **ICMP**: 172.31.0.0/16, 0.0.0.0/0

#### Private Security Group (Redis Nodes)
- **Redis (6379)**: 0.0.0.0/0
- **Redis Cluster (16379-16384)**: 0.0.0.0/0
- **SSH (22)**: 172.31.0.0/16, 0.0.0.0/0
- **ICMP**: 172.31.0.0/16, 0.0.0.0/0

## 📋 Post-Deployment

### Access Your Infrastructure

#### 1. Connect to Bastion Host
```bash
ssh -i my-key-aws.pem ubuntu@<PUBLIC_IP>
```

#### 2. Connect to Redis Nodes (via Bastion)
```bash
# Direct jump connection
ssh -i my-key-aws.pem -J ubuntu@<BASTION_IP> ubuntu@<REDIS_NODE_IP>

# Or through bastion
ssh -i my-key-aws.pem ubuntu@<BASTION_IP>
# Then from bastion:
ssh ubuntu@<REDIS_NODE_PRIVATE_IP>
```

#### 3. Get Resource Information
```bash
# From terraform directory
terraform output

# Example output:
# public-instance-ip = "15.206.163.194"
# private-instance1-ip = "10.0.2.219"
# private-instance2-ip = "10.0.3.185"
# private-instance3-ip = "10.0.4.189"
```

### Redis Cluster Setup

After infrastructure deployment, configure Redis clustering:

```bash
# On each Redis node, install Redis
sudo apt update
sudo apt install redis-server -y

# Configure Redis for clustering
sudo nano /etc/redis/redis.conf
# Uncomment and modify:
# cluster-enabled yes
# cluster-config-file nodes.conf
# cluster-node-timeout 5000

# Restart Redis
sudo systemctl restart redis-server

# Create cluster (run from any node)
redis-cli --cluster create \
  10.0.2.219:6379 \
  10.0.3.185:6379 \
  10.0.4.189:6379 \
  --cluster-replicas 0
```

## 🧹 Cleanup

### Destroy Infrastructure

#### Method 1: Terraform
```bash
cd terraform
terraform destroy --auto-approve
```

#### Method 2: Jenkins Pipeline
- Set parameter: `action=destroy`
- Run the pipeline

#### Method 3: AWS Resource Cleanup
```bash
# Clean up all resources including orphaned ones
./cleanup-aws-resources.sh
```

### Cleanup Scripts

| Script | Purpose |
|--------|---------|
| `quick-cleanup.sh` | Automated cleanup of unused VPCs and EIPs |
| `cleanup-aws-resources.sh` | Interactive cleanup with confirmation |
| `cleanup-conflicts.sh` | Clean up conflicting security groups and routes |

## 📁 Project Structure

```
redisdemo/
├── terraform/                 # Terraform infrastructure code
│   ├── main.tf               # Main configuration
│   ├── provider.tf           # AWS provider configuration
│   ├── variable.tf           # Global variables
│   ├── output.tf             # Output definitions
│   ├── backend.tf            # State backend configuration
│   ├── instances/            # EC2 instance module
│   ├── vpc/                  # VPC module
│   ├── subnets/              # Subnet module
│   ├── security_group/       # Security group module
│   └── vpc_peering/          # VPC peering module
├── ansible/                  # Ansible configuration
│   └── roles/                # Ansible roles
├── aws_ec2.yaml             # Ansible AWS inventory
├── playbook.yml             # Main Ansible playbook
├── Jenkinsfile              # Jenkins pipeline definition
├── deploy-infrastructure.sh  # Automated deployment script
├── cleanup-aws-resources.sh # Resource cleanup script
├── quick-cleanup.sh         # Quick automated cleanup
└── README.md               # This file
```

## 🔗 Useful Commands

### AWS CLI Commands
```bash
# List all VPCs
aws ec2 describe-vpcs --region ap-south-1

# List all instances
aws ec2 describe-instances --region ap-south-1

# List Elastic IPs
aws ec2 describe-addresses --region ap-south-1

# Check service limits
aws service-quotas get-service-quota --service-code ec2 --quota-code L-F678F1CE
```

### Terraform Commands
```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0
```

### Ansible Commands
```bash
# Test connectivity
ansible all -i aws_ec2.yaml -m ping

# Run specific playbook
ansible-playbook -i aws_ec2.yaml playbook.yml --tags redis

# Check inventory
ansible-inventory -i aws_ec2.yaml --graph
```

## 📞 Support

For issues and questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review AWS CloudTrail logs for API errors
3. Check Jenkins build logs for pipeline issues
4. Verify AWS service limits and quotas

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Happy Deploying! 🚀**
# Redis_demo
