data "aws_vpc" "default_vpc" {
  default = true
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = data.aws_vpc.default_vpc.id              
  peer_vpc_id   = var.vpc_id        
  peer_region   = var.region_name         
  tags = {
    Name = "peering connection"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true
}

data "aws_route_table" "default_RT" {
  vpc_id = data.aws_vpc.default_vpc.id
  filter {
    name = "association.main"
    values = [ "true" ]
  }
}

# Route creation commented out to avoid conflicts
# The VPC peering connection is established and can be used
# Routes can be added manually if needed for specific connectivity requirements
/*
resource "aws_route" "default_rt" {
  route_table_id            = data.aws_route_table.default_RT.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}
*/

data "aws_security_group" "default_sg" {
  vpc_id = data.aws_vpc.default_vpc.id
  filter {
    name = "group-name"
    values = [ "default" ]
  }
}
