variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = "mysql"
}
variable "engine_version" {
  description = "The database engine version to use."
  type        = string
  default     = "8.0"
}
variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "wordpress"
}
variable "db_username" {
  description = "The username for the database."
  type        = string
  default     = "admin_user"
}
variable "db_instance_class" {
  description = "The instance class for the database."
  type        = string
  default     = "db.t3.micro"
}
variable "db_allocated_storage" {
  description = "The allocated storage for the database."
  type        = number
  default     = 20
}
variable "db_storage_type" {
  description = "The storage type for the database."
  type        = string
  default     = "gp2"
}
variable "db_parameter_group_name" {
  description = "The name of the DB parameter group."
  type        = string
  default     = "default.mysql8.0"
}
variable "db_tags" {
  description = "A map of tags to assign to the database instance."
  type        = map(string)
  default     = {
    Name = "dev"
    Environment = "dev"
    Application = "wordpress"
    Owner = "admin"
    Project = "wordpress"
    CostCenter = "dev"
    Department = "IT"
    Team = "devops"
    Purpose = "dev"
    ManagedBy = "terraform"
    CreatedBy = "terraform"
    CreatedOn = "2023-10-01"
    UpdatedOn = "2023-10-01"
    UpdatedBy = "terraform"
    Version = "1.0"
    TerraformVersion = "1.0.0"
    AWSRegion = "ap-south-1"
  }
  
}
