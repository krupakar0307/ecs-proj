output "vpc_id" {
  value = aws_vpc.vpc-dev.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc-dev.cidr_block
}

output "aws_private_subnets" {
  value = aws_subnet.private-subnets[*].cidr_block
}

output "aws_public_subnets" {
  value = aws_subnet.public-subnet[*].cidr_block
}

output "aws_private_subnets_id" {
  value = aws_subnet.private-subnets[*].id
}

output "aws_public_subnets_id" {
  value = aws_subnet.public-subnet[*].id
}