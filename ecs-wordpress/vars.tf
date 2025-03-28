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
  default = "tester"
  description = "name of the service"
  type = string
}
variable "service_domain" {
  default = "wordpress.app.krupakar.in"
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
        })), [])
    }))
    default = {
        service = {
            image         = "wordpress:latest"
            memory        = 256
            cpu           = 512
            port_mappings = [
                {
                    container_port = 80
                    host_port      = 80
                    protocol       = "tcp"
                }
            ]
        }

    }
}