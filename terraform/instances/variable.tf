variable "public-sg-id" {
  type = string
}

variable "private-sg-id" {
  type = string
}

variable "pub-sub-id" {
  type = string  
}

variable "pri-sub-1-id" {
  type = string  
}

variable "pri-sub-2-id" {
  type = string  
}

variable "pri-sub-3-id" {
  type = string
}

variable "ami-id" {
  type = string
  default = "ami-09b0a86a2c84101e1"
}

variable "instance-type" {
  type = string
  default = "t3.micro"
}

variable "key-name" {
  type = string
  default = "my-key-aws"
}
