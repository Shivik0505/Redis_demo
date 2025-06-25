# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Random suffix to avoid naming conflicts
resource "random_id" "sg_suffix" {
  byte_length = 4
}

# Default VPC Security Group
resource "aws_security_group" "default_vpc_sg" {
  vpc_id = data.aws_vpc.default.id
  name   = "default-vpc-sg-${random_id.sg_suffix.hex}"
  
  # Allow inbound traffic from the custom VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]   
  }

  # Allow all outbound traffic (optional)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"        # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-vpc-sg-${random_id.sg_suffix.hex}"
  }
}

# Public Security Group
resource "aws_security_group" "public-SG" {
  vpc_id = var.vpc_id   # Corrected to use 'var.vpc_id'

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # Allow all outbound traffic
  }

  # Ingress rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow traffic from any IP address
  }

  # Ingress rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for ICMP (ping)
  ingress {
    from_port        = -1                # ICMP type (all types)
    to_port          = -1                # ICMP code (all codes)
    protocol         = "icmp"
    cidr_blocks      = ["172.31.0.0/16", "0.0.0.0/0"]  # Allow from default VPC and anywhere
     
    ipv6_cidr_blocks = []
  }

  tags = {
    Name = "public-sg"
  }
}

# Private Security Group
resource "aws_security_group" "private-SG" {
  vpc_id = var.vpc_id   # Corrected to use 'var.vpc_id'

  # Ingress rule for Redis (port 6379) allowing traffic from any IP address
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP address
  }
  
  # Ingress rule for Redis cluster allowing traffic from any IP address
  ingress {
    from_port   = 16379
    to_port     = 16384
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP address
  }

  # Ingress rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", "0.0.0.0/0"]  # Allow SSH from default VPC and anywhere
  }

  # Ingress rule for ICMP (ping)
  ingress {
    from_port        = -1                # ICMP type (all types)
    to_port          = -1                # ICMP code (all codes)
    protocol         = "icmp"
    cidr_blocks      = ["172.31.0.0/16", "0.0.0.0/0"]  # Allow from default VPC and anywhere
    ipv6_cidr_blocks = []
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"        # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}
