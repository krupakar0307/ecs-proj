provider "aws" {
    region = "ap-south-1"
}

data "aws_vpc" "vpc-dev" {
    tags = { Name = "dev" }
}

data "aws_subnets" "private" {
    filter {
        name   = "tag:Name"
        values = ["*private*"]
    }
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.vpc-dev.id]
    }
}

data "aws_subnet" "private_subnets" {
    count = length(data.aws_subnets.private.ids)

    id = data.aws_subnets.private.ids[count.index]
}
resource "aws_db_subnet_group" "rds_subnet_group" {
    name        = "rds-subnet-group"

    subnet_ids  = data.aws_subnet.private_subnets[*].id
    description = "RDS subnet group"
}

resource "aws_security_group" "rds_sg" {
    name_prefix = "rds-sg-"
    vpc_id      = data.aws_vpc.vpc-dev.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"] # Adjust CIDR as per your VPC
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "random_password" "rds_password" {
    length           = 16
    special          = true
    override_special = "_%#"
}

resource "aws_db_instance" "rds_instance" {
    engine               = var.engine
    engine_version       = var.engine_version
    instance_class       = var.db_instance_class
    allocated_storage    = var.db_allocated_storage
    db_name              = var.db_name
    storage_type         = var.db_storage_type
    backup_retention_period = var.db_backup_retention_period
    parameter_group_name = var.db_parameter_group_name
    performance_insights_enabled = var.db_enable_performance_insights
    storage_encrypted    = true
    username             = var.db_username
    password             = random_password.rds_password.result
    publicly_accessible  = false
    identifier           = "rds-${var.db_name}"
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
    # snapshot_identifier =   aws_db_instance.rds_instance.snapshot_id
    skip_final_snapshot      = true
    final_snapshot_identifier = "final-snapshot-${var.db_name}-${uuid()}"
    apply_immediately   = true
    tags = var.db_tags
}