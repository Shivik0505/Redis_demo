variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "pri-sub1-az" {
  type = string
  default = "ap-south-1a"
}

variable "pri-sub2-az" {
  type = string
  default = "ap-south-1b"
}

variable "pri-sub3-az" {
  type = string
  default = "ap-south-1c"
}

variable "pub-sub-az" {
  type = string
  default = "ap-south-1b"
}

variable "pub-cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "pri-sub-1-cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "pri-sub-2-cidr" {
  type = string
  default = "10.0.3.0/24"
}

variable "pri-sub-3-cidr" {
  type = string
  default = "10.0.4.0/24"
}