# 🚀 Redis Infrastructure - Quick Reference Card

## 🔧 Essential Configuration Changes

### 1. **Region Setup** (Required)
```bash
# Edit terraform/provider.tf
provider "aws" {
  region = "your-region"  # Change from ap-south-1
}
```

### 2. **AMI ID Update** (Required for different regions)
```bash
# Edit terraform/instances/variable.tf
variable "ami-id" {
  default = "ami-xxxxxxxxx"  # Update for your region
}
```

### 3. **Instance Size** (Optional)
```bash
# Edit terraform/instances/variable.tf
variable "instance-type" {
  default = "t3.small"  # Change from t3.micro if needed
}
```

## ⚡ Quick Deployment Commands

### **Option 1: One-Click Deployment**
```bash
git clone https://github.com/JayLikhare316/redisdemo.git
cd redisdemo
chmod +x *.sh
./deploy-infrastructure.sh
```

### **Option 2: Manual Terraform**
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### **Option 3: Jenkins Pipeline**
1. Create Pipeline job with GitHub repo
2. Add AWS credentials: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
3. Run with parameters: `action=apply`, `autoApprove=true`

## 🆘 Emergency Fixes

### **AWS Limits Exceeded**
```bash
./quick-cleanup.sh  # Automatic cleanup
# OR
./cleanup-aws-resources.sh  # Interactive cleanup
```

### **Key Pair Missing**
```bash
aws ec2 create-key-pair --key-name my-key-aws --region your-region --query 'KeyMaterial' --output text > my-key-aws.pem
chmod 400 my-key-aws.pem
```

### **Terraform State Issues**
```bash
cd terraform
terraform force-unlock <LOCK_ID>
```

## 🔍 Verification Commands

### **Check Deployment Status**
```bash
# Terraform outputs
terraform output

# AWS resources
aws ec2 describe-instances --region your-region --output table
aws ec2 describe-vpcs --region your-region --output table
```

### **Test Connectivity**
```bash
# SSH to bastion
ssh -i my-key-aws.pem ubuntu@<PUBLIC_IP>

# SSH to private instances
ssh -i my-key-aws.pem -J ubuntu@<BASTION_IP> ubuntu@<PRIVATE_IP>
```

## 🗑️ Cleanup Commands

### **Complete Cleanup**
```bash
cd terraform
terraform destroy --auto-approve
./cleanup-aws-resources.sh
```

## 📋 AMI IDs by Region

| Region | Ubuntu 22.04 LTS AMI |
|--------|---------------------|
| us-east-1 | ami-0c02fb55956c7d316 |
| us-west-2 | ami-0892d3c7ee96c0bf7 |
| eu-west-1 | ami-0905a3c97561e0b69 |
| ap-south-1 | ami-09b0a86a2c84101e1 |
| ap-southeast-1 | ami-0df7a207adb9748c7 |

## 🎯 Success Indicators

✅ **Deployment Successful:**
- 4 EC2 instances running
- Public IP accessible via SSH
- Private instances reachable through bastion
- No Terraform errors

❌ **Common Failures:**
- VpcLimitExceeded → Run cleanup scripts
- InvalidKeyPair → Create key pair manually
- AddressLimitExceeded → Release unused EIPs

## 💰 Estimated Costs

- **4 x t3.micro**: ~$33.60/month
- **NAT Gateway**: ~$32.40/month
- **Elastic IP**: ~$3.60/month
- **Total**: ~$69.60/month

---

**🚀 Ready to Deploy? Run: `./deploy-infrastructure.sh`**
