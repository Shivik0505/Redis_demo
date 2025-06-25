module "vpc" {
  source           = "./vpc"
  vpc_cidr         = var.vpc_cidr
  nat-gat-id       = module.subnet.nat-gat-id
  pri-sub3-id      = module.subnet.pri-sub-3-id
  pri-sub2-id      = module.subnet.pri-sub-2-id
  pri-sub1-id      = module.subnet.pri-sub-1-id
  pub-sub-id       = module.subnet.pub-sub-id
  vpc_peering_id   = module.peering.vpc_peering_id
  default_vpc_cidr = module.peering.default_vpc_cidr

}

module "subnet" {
  source   = "./subnets"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

module "security_groups" {
  source   = "./security_group"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

module "instance" {
  source        = "./instances"
  pri-sub-1-id  = module.subnet.pri-sub-1-id
  pri-sub-2-id  = module.subnet.pri-sub-2-id
  pri-sub-3-id  = module.subnet.pri-sub-3-id
  pub-sub-id    = module.subnet.pub-sub-id
  private-sg-id = module.security_groups.private-sg-id
  public-sg-id  = module.security_groups.public-sg-id
}

module "peering" {
  source   = "./vpc_peering"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}