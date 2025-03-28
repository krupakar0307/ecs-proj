# ECS Module

This module automates the deployment of an ECS service in AWS using Fargate. It includes the creation of an ECS cluster, task definition, service, IAM roles, autoscaling, and DNS configuration. The module is designed to spin up containers in private subnets and integrate seamlessly with an Application Load Balancer (ALB) and Route 53 for domain management.

## Features

- Creates an ECS cluster and task definition.
- Deploys the ECS service in private subnets within the specified VPC.
- Configures the service to use Fargate as the launch type.
- Automatically fetches private subnets based on the provided VPC name.
- Sets up autoscaling based on CPU and memory thresholds.
- Attaches the ECS service to an ALB with HTTP to HTTPS redirection.
- Configures DNS records in Route 53 with SSL certificates issued by ACM.
- Creates required IAM roles, including CloudWatch log stream policies for logging.

## Usage

Below is an example of how to use this module in your Terraform configuration:

```hcl
provider "aws" {
    region = var.region
}

module "ecs" {
    source          = "../modules/ecs"
    region          = var.region
    vpc_name        = var.vpc_name
    environment     = var.environment
    service         = var.service
    service_domain  = var.service_domain
    zone_id         = var.zone_id

    # Define container definitions for the ECS service
    container_definitions = {
        service = {
            image         = var.container_definitions["service"].image
            memory        = var.container_definitions["service"].memory
            cpu           = var.container_definitions["service"].cpu
            port_mappings = var.container_definitions["service"].port_mappings
            environment   = [
                {
                    name  = "WORDPRESS_DB_USER"
                    value = local.db_creds["db_user"] 
                },
                {
                    name  = "WORDPRESS_DB_PASS"
                    value = local.db_creds["db_user"]
                }
            ]
        }
    }
}
```

### Inputs:

`region` - The AWS region where the ECS service will be deployed.

`vpc_name` - The name of the VPC where the ECS service will be deployed. Private subnets will be automatically fetched.

`environment` - The environment (e.g., dev, staging, prod) for the ECS service.

`service` - The name of the ECS service.

`service_domain` - The domain name for the ECS service.

`zone_id` - The Route 53 hosted zone ID for DNS configuration.

`container_definitios` - A map defining the container configurations, including image, memory, CPU, port mappings, and environment variables.


### Outputs

This module provides the following outputs:

`dns_name` - The DNS name of the ALB.

`dns` - The fully qualified domain name (FQDN) of the service in Route 53.
`ecs_task_execution_role_name` - The name of the IAM role for ECS task execution.

### Prerequisites

- Ensure your hosted zone is configured in Route 53.
- Provide the hosted zone ID and DNS name in your vars.tf file.
- SSL certificates for the domain must be issued via ACM (handled automatically by the module).

### Notes

The ECS service is deployed in private subnets for security.
Autoscaling is configured to adjust based on CPU and memory usage thresholds.
HTTP to HTTPS redirection is enabled for secure communication.
License

This module is open-source and available under the MIT License.

!!!
