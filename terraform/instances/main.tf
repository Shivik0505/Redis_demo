# Public EC2 Instance
resource "aws_instance" "redis-public" {
  ami           = var.ami-id
  instance_type = var.instance-type
  subnet_id     = var.pub-sub-id
  associate_public_ip_address = "true"
  security_groups = [var.public-sg-id]
  key_name = var.key-name
  tags = {
    Name = "redis-public"
  }
}

# Private EC2 1 Instance
resource "aws_instance" "redis-private-1" {
  ami           = var.ami-id
  instance_type = var.instance-type
  subnet_id     = var.pri-sub-1-id
  associate_public_ip_address = "false"
  security_groups = [var.private-sg-id]
  key_name = var.key-name

  tags = {
    Name = "redis-private-1"
  }
}

# Private EC2 2 Instance
resource "aws_instance" "redis-private-2" {
  ami           = var.ami-id
  instance_type = var.instance-type
  subnet_id     = var.pri-sub-2-id
  associate_public_ip_address = "false"
  security_groups = [var.private-sg-id]  
   key_name = var.key-name

  tags = {
    Name = "redis-private-2"
  }
}

# Private EC2 3 Instance
resource "aws_instance" "redis-private-3" {
  ami           = var.ami-id
  instance_type = var.instance-type
  subnet_id     = var.pri-sub-3-id
  associate_public_ip_address = "false"
  security_groups = [var.private-sg-id]
   key_name = var.key-name

  tags = {
    Name = "redis-private-3"
  }
}