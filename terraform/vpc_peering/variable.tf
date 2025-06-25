variable "region_name" {
  default = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
    type = string
}

variable "default_vpc_cidr" {
  type = string
  default = "172.31.0.0/16"
}