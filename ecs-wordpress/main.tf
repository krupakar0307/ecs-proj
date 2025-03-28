provider "aws" {
    region = var.region
}
module "ecs" {
    source = "../modules/ecs"
    region = var.region
    vpc_name = var.vpc_name
    environment = var.environment
    service = var.service
    service_domain = var.service_domain
    zone_id = var.zone_id
    # container_definitions = var.container_definitions
    # Environment variables should be handled within the ECS module or passed as part of container_definitions
    container_definitions = {
        service = {
            image         = var.container_definitions["service"].image
            memory        = var.container_definitions["service"].memory
            cpu           = var.container_definitions["service"].cpu
            port_mappings = var.container_definitions["service"].port_mappings
            environment = [
                {
                    name  = "WORDPRESS_DB_HOST"
                    value = local.db_creds["db_host"]
                },
                {
                    name  = "WORDPRESS_DB_NAME"
                    value = local.db_creds["db_name"]
                },
                {
                    name  = "WORDPRESS_DB_USER"
                    value = local.db_creds["db_user"]
                },
                {
                    name  = "WORDPRESS_DB_PASSWORD"
                    value = local.db_creds["db_pass"]
                }
            ]
        }
    }
}

# Fetch Secrets from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_secret" {
  name = "${var.environment}/rds-creds/rds-wordpress"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}


output "dns_name" {
  value = module.ecs.dns
}