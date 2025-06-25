# VPC
resource "aws_vpc" "redis-VPC" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "redis-VPC"
  }
}

#--------------------IGW-------------------------
# Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.redis-VPC.id

  tags = {
    Name = "IGW"
  }
}

#--------------------public RT-------------------------

#public route table
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.redis-VPC.id

  route {
    cidr_block = var.pub-rt-cidr
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = var.pub-sub-id
  route_table_id = aws_route_table.public-RT.id
}

resource "aws_route" "RT-1" {
  route_table_id = aws_route_table.public-RT.id
  destination_cidr_block = var.default_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_id
}


#--------------------private RT-------------------------

# private route table
resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.redis-VPC.id

  route {
    cidr_block     = var.pri-rt-cidr
    nat_gateway_id = var.nat-gat-id
  }

  tags = {
    Name = "private-route-table"
  }
}


# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = var.pri-sub1-id
  route_table_id = aws_route_table.private-RT.id
}

resource "aws_route_table_association" "private_association2" {
  subnet_id = var.pri-sub2-id
  route_table_id = aws_route_table.private-RT.id
}

resource "aws_route_table_association" "private_association3" {
  subnet_id = var.pri-sub3-id
  route_table_id = aws_route_table.private-RT.id
}


resource "aws_route" "RT-2" {
  route_table_id = aws_route_table.private-RT.id
  destination_cidr_block = var.default_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_id
}