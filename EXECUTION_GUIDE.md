# 🚀 Redis Infrastructure - Step-by-Step Execution Guide

## 📋 Pre-Deployment Checklist

### ✅ **Step 1: Environment Setup**

1. **Install Required Tools:**
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
   unzip terraform_1.5.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Install Ansible
   sudo apt update
   sudo apt install ansible -y
   ```

2. **Configure AWS Credentials:**
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., ap-south-1)
   # Enter output format (json)
   ```

3. **Verify Setup:**
   ```bash
   aws sts get-caller-identity
   terraform version
   ansible --version
   ```

### ✅ **Step 2: Repository Setup**

1. **Clone Repository:**
   ```bash
   git clone https://github.com/JayLikhare316/redisdemo.git
   cd redisdemo
   ```

2. **Make Scripts Executable:**
   ```bash
   chmod +x *.sh
   ```

## 🔧 Configuration Changes

### ✅ **Step 3: Customize Configuration**

#### **3.1 Region Configuration**
Edit `terraform/provider.tf`:
```hcl
provider "aws" {
  region = "your-preferred-region"  # Change from ap-south-1 if needed
}
```

#### **3.2 Instance Configuration**
Edit `terraform/instances/variable.tf`:
```hcl
variable "ami-id" {
  type = string
  default = "ami-xxxxxxxxx"  # Update AMI ID for your region
}

variable "instance-type" {
  type = string
  default = "t3.micro"  # Change instance size if needed
}

variable "key-name" {
  type = string
  default = "my-key-aws"  # Change key pair name if needed
}
```

#### **3.3 Network Configuration (Optional)**
Edit `terraform/vpc/main.tf` if you need different CIDR blocks:
```hcl
resource "aws_vpc" "redis-VPC" {
  cidr_block = "10.0.0.0/16"  # Change if conflicts with existing networks
}
```

#### **3.4 Availability Zones (Optional)**
Edit subnet configurations in `terraform/subnets/main.tf`:
```hcl
availability_zone = "your-region-a"  # Update AZ names for your region
availability_zone = "your-region-b"
availability_zone = "your-region-c"
```

### ✅ **Step 4: AMI ID Reference Table**

| Region | AMI ID (Ubuntu 22.04 LTS) |
|--------|---------------------------|
| us-east-1 | ami-0c02fb55956c7d316 |
| us-west-2 | ami-0892d3c7ee96c0bf7 |
| eu-west-1 | ami-0905a3c97561e0b69 |
| ap-south-1 | ami-09b0a86a2c84101e1 |
| ap-southeast-1 | ami-0df7a207adb9748c7 |

*Find latest AMI IDs: `aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" --query 'Images[*].[ImageId,CreationDate]' --output table`*

## 🚀 Deployment Execution

### ✅ **Method 1: Automated Script Deployment (Recommended)**

1. **Check AWS Limits (Important!):**
   ```bash
   # Check current VPC usage
   aws ec2 describe-vpcs --region your-region --query 'Vpcs[].{VpcId:VpcId,IsDefault:IsDefault}' --output table
   
   # Check Elastic IP usage
   aws ec2 describe-addresses --region your-region --output table
   ```

2. **Clean Up Resources (If Needed):**
   ```bash
   # If you hit limits, run cleanup
   ./quick-cleanup.sh
   ```

3. **Deploy Infrastructure:**
   ```bash
   ./deploy-infrastructure.sh
   ```

4. **Monitor Progress:**
   - Script will show real-time progress
   - Takes approximately 5-10 minutes
   - Watch for any error messages

### ✅ **Method 2: Manual Terraform Deployment**

1. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   ```

2. **Plan Deployment:**
   ```bash
   terraform plan -out=tfplan
   ```

3. **Review Plan:**
   - Check resources to be created
   - Verify configurations
   - Ensure no conflicts

4. **Apply Deployment:**
   ```bash
   terraform apply tfplan
   ```

5. **Save Outputs:**
   ```bash
   terraform output > ../deployment-outputs.txt
   ```

### ✅ **Method 3: Jenkins CI/CD Pipeline**

#### **3.1 Jenkins Setup:**

1. **Install Jenkins Plugins:**
   - Git Plugin
   - Pipeline Plugin
   - AWS CLI Plugin
   - Ansible Plugin

2. **Configure AWS Credentials in Jenkins:**
   - Go to "Manage Jenkins" → "Manage Credentials"
   - Add "Secret text" credentials:
     - ID: `AWS_ACCESS_KEY_ID`
     - Secret: Your AWS Access Key
   - Add another "Secret text":
     - ID: `AWS_SECRET_ACCESS_KEY`
     - Secret: Your AWS Secret Key

#### **3.2 Create Jenkins Job:**

1. **Create New Pipeline Job:**
   - New Item → Pipeline
   - Name: `redis-infrastructure-deployment`

2. **Configure Pipeline:**
   ```groovy
   pipeline {
       agent any
       parameters {
           choice(name: 'action', choices: ['apply', 'destroy'], description: 'Terraform action')
           booleanParam(name: 'autoApprove', defaultValue: false, description: 'Auto approve terraform apply')
       }
       // ... rest of pipeline from Jenkinsfile
   }
   ```

3. **Configure SCM Polling:**
   - Build Triggers → Poll SCM
   - Schedule: `H/5 * * * *` (every 5 minutes)

#### **3.3 Run Pipeline:**

1. **Trigger Build:**
   - Click "Build with Parameters"
   - Select `action: apply`
   - Check `autoApprove: true`
   - Click "Build"

2. **Monitor Execution:**
   - Watch console output
   - Check each stage completion
   - Review any errors

## 📋 Post-Deployment Steps

### ✅ **Step 5: Verify Deployment**

1. **Check Terraform Outputs:**
   ```bash
   cd terraform
   terraform output
   ```

2. **Verify AWS Resources:**
   ```bash
   # Check instances
   aws ec2 describe-instances --region your-region --query 'Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' --output table
   
   # Check VPC
   aws ec2 describe-vpcs --region your-region --filters "Name=tag:Name,Values=redis-VPC" --output table
   ```

3. **Test Connectivity:**
   ```bash
   # Test SSH to bastion host
   ssh -i my-key-aws.pem ubuntu@<PUBLIC_IP>
   
   # Test jump to private instances
   ssh -i my-key-aws.pem -J ubuntu@<BASTION_IP> ubuntu@<PRIVATE_IP>
   ```

### ✅ **Step 6: Redis Configuration**

1. **Connect to Each Redis Node:**
   ```bash
   # Connect to each private instance and run:
   sudo apt update
   sudo apt install redis-server -y
   
   # Configure Redis for clustering
   sudo sed -i 's/# cluster-enabled yes/cluster-enabled yes/' /etc/redis/redis.conf
   sudo sed -i 's/# cluster-config-file nodes-6379.conf/cluster-config-file nodes.conf/' /etc/redis/redis.conf
   sudo sed -i 's/# cluster-node-timeout 15000/cluster-node-timeout 5000/' /etc/redis/redis.conf
   sudo sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
   
   # Restart Redis
   sudo systemctl restart redis-server
   sudo systemctl enable redis-server
   ```

2. **Create Redis Cluster:**
   ```bash
   # From any Redis node, create cluster
   redis-cli --cluster create \
     10.0.2.219:6379 \
     10.0.3.185:6379 \
     10.0.4.189:6379 \
     --cluster-replicas 0
   ```

3. **Test Redis Cluster:**
   ```bash
   # Test cluster status
   redis-cli -c -h 10.0.2.219 cluster nodes
   
   # Test data operations
   redis-cli -c -h 10.0.2.219 set test-key "Hello Redis Cluster"
   redis-cli -c -h 10.0.3.185 get test-key
   ```

## 🔧 Troubleshooting Guide

### ❌ **Common Issues & Solutions**

#### **Issue 1: VpcLimitExceeded**
```bash
# Solution: Clean up unused VPCs
./cleanup-aws-resources.sh
# Choose option 1 to delete unused VPCs
```

#### **Issue 2: AddressLimitExceeded**
```bash
# Solution: Release unused Elastic IPs
./cleanup-aws-resources.sh
# Choose option 2 to release unassociated EIPs
```

#### **Issue 3: InvalidKeyPair.NotFound**
```bash
# Solution: Create key pair manually
aws ec2 create-key-pair --key-name my-key-aws --region your-region --query 'KeyMaterial' --output text > my-key-aws.pem
chmod 400 my-key-aws.pem
```

#### **Issue 4: Terraform State Lock**
```bash
# Solution: Force unlock (use carefully)
cd terraform
terraform force-unlock <LOCK_ID>
```

#### **Issue 5: SSH Connection Issues**
```bash
# Check security groups
aws ec2 describe-security-groups --region your-region --filters "Name=group-name,Values=public-sg" --output table

# Verify key permissions
chmod 400 my-key-aws.pem

# Test with verbose SSH
ssh -v -i my-key-aws.pem ubuntu@<PUBLIC_IP>
```

## 🧹 Cleanup Instructions

### ✅ **Complete Infrastructure Cleanup**

1. **Terraform Destroy:**
   ```bash
   cd terraform
   terraform destroy --auto-approve
   ```

2. **Manual Resource Cleanup:**
   ```bash
   ./cleanup-aws-resources.sh
   ```

3. **Verify Cleanup:**
   ```bash
   # Check no resources remain
   aws ec2 describe-instances --region your-region --query 'Reservations[].Instances[?State.Name!=`terminated`]' --output table
   aws ec2 describe-vpcs --region your-region --filters "Name=is-default,Values=false" --output table
   ```

## 📊 Resource Costs (Estimated)

| Resource | Quantity | Monthly Cost (USD) |
|----------|----------|-------------------|
| t3.micro instances | 4 | ~$33.60 |
| NAT Gateway | 1 | ~$32.40 |
| Elastic IP | 1 | ~$3.60 |
| **Total** | | **~$69.60/month** |

*Costs may vary by region and usage patterns*

## 🎯 Success Criteria

### ✅ **Deployment Successful When:**

- [ ] All 4 EC2 instances are running
- [ ] Bastion host accessible via SSH
- [ ] Private instances accessible via bastion
- [ ] Redis cluster operational
- [ ] All security groups configured correctly
- [ ] VPC peering established
- [ ] No Terraform errors in final apply

### 🎉 **You're Done!**

Your Redis infrastructure is now deployed and ready for use. The cluster can handle high availability and scaling requirements for your applications.

---

**Need Help?** Check the main README.md for detailed troubleshooting and configuration options.
