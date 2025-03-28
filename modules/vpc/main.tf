provider "aws" {
  region = var.region
}
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.31.0"
    }
  }
}

#######

resource "aws_vpc" "vpc-dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
    Environment = var.Environment
  }
}

######

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-dev.id
  tags = {
    Name = "igw-${var.Environment}"
  }
}

#####

resource "aws_subnet" "private-subnets" {
  count = length(var.private_cidr)
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = element(var.private_cidr, count.index)
  availability_zone = element(var.a_z, count.index)
  tags = {
    "Name" = "private-subnet-${count.index+1}-${var.Environment}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc-dev.id
  count = length(var.public_cidr)
  cidr_block = element(var.public_cidr, count.index)
  availability_zone = element(var.a_z, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public-subnet-${count.index+1}-${var.Environment}"
    "kubernenets.io/role/elb" = "1"     
   }
}


#######
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    "Name" = "eip_${var.Environment}"
  }
}
resource "aws_nat_gateway" "nat" {
  count = 1
  allocation_id = aws_eip.eip.id
  subnet_id = element(aws_subnet.public-subnet[*].id, 0)
  tags = {
    "Name" = "nat-dev"
  }
}

############

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }
  tags = {
    "Name" = "private_rt-${var.Environment}"
  }
}
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "public_rt-${var.Environment}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)
  subnet_id = element(aws_subnet.private-subnets[*].id, count.index)
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)
  subnet_id = element(aws_subnet.public-subnet[*].id, count.index)
  route_table_id = aws_route_table.public-rt.id
}