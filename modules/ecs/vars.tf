variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "dev"
}
variable "environment" {
  description = "value of the environment"
  type        = string
  default = "dev"
}
variable "region" {
  default = "ap-south-1"
  type = string
}
variable "service" {
  default = "wordpress"
  description = "name of the service"
  type = string
}
variable "service_domain" {
  default = "microservic.app.krupakar.in"
  description = "domain name for the service"
  type = string
}
variable "zone_id" {
  default = "Z0389416OBIBLKMC1E32"
  type = string
  description = "value"
}
variable "container_definitions" {
    description = "Map object for container definitions"
    type = map(object({
        image         = string
        memory        = number
        cpu           = number
        port_mappings = list(object({
            container_port = number
            host_port      = number
            protocol       = string
        }))
        environment = optional(list(object({
            name  = string
            value = string
        })))
    }))
    default = {
        service = {
            image         = "nginx:latest"
            memory        = 256
            cpu           = 512
            port_mappings = [
                {
                    container_port = 80
                    host_port      = 80
                    protocol       = "tcp"
                }
            ]
            # environment = [
            #     {
            #         name  = "WORDPRESS_DB_USER"
            #         value = "jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string).db_user"
            #     }
            #     # {
            #     #     name  = "WORDPRESS_DB_PASSWORD"
            #     #     value = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string).db_pass
            #     # },
            #     # {
            #     #     name  = "WORDPRESS_DB_HOST"
            #     #     value = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string).db_host
            #     # },
            #     # {
            #     #     name  = "WORDPRESS_DB_NAME"
            #     #     value = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string).db_name
            #     # }
            # ]
        }

    }
}