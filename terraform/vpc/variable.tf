variable "vpc_cidr" {
    type = string
}

variable "nat-gat-id" {
    type = string
}

variable "pri-rt-cidr" {
    type = string
    default = "0.0.0.0/0"
}

variable "pub-rt-cidr" {
    type = string
    default = "0.0.0.0/0"
}

variable "pub-sub-id" {
  type = string
}

variable "pri-sub1-id" {
  type = string
}

variable "pri-sub2-id" {
  type = string
}


variable "pri-sub3-id" {
  type = string
}

variable "default_vpc_cidr" {
  type = string
}

variable "vpc_peering_id" {
  type = string
}