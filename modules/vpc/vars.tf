variable "region" {
  type = string
#   default = "ap-south-1"
}

variable "vpc_cidr" {
  type = string
#   default = "10.0.0.0/16"
}
variable "vpc_name" {
  type = string
#   default = "vpc-dev"
}
variable "Environment" {
  type = string
  default = "Dev"
}
variable "private_cidr" {
  type = list(string)
  description = "Provide private subnet cidr range"
#   default = [ "10.0.1.0/24","10.0.2.0/24" ]
}

variable "a_z" {
  type = list(string)
  description = "Provide az's"
#   default = [ "ap-south-1a","ap-south-1b" ]
}

variable "public_cidr" {
  type = list(string)
  description = "Provide public subnet cidr range"
#   default = [ "10.0.3.0/24","10.0.4.0/24" ]
}