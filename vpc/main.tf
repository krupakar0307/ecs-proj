provider "aws" {
  region = ap-south-1
}

module "vpc" {
  source            =   "../modules/vpc"
  region            =   "ap-south-1"
  vpc_name          =   "dev"
  vpc_cidr          =   "10.0.0.0/16"
  a_z               =   ["ap-south-1a", "ap-south-1b"]
  public_cidr       =   ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidr      =   ["10.0.3.0/24", "10.0.4.0/24"]
}