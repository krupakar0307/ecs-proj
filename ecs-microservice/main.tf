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
            environment = []
        }
    }
}
