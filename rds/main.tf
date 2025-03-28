provider "aws" {
  region = "ap-south-1"
}
module "rds" {
  source = "../modules/rds"
  engine = var.engine
  engine_version = var.engine_version
  db_name = var.db_name
  db_username = var.db_username
  db_instance_class = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_storage_type = var.db_storage_type
  db_parameter_group_name = var.db_parameter_group_name
  db_backup_retention_period = 7
  db_multi_az = false
  db_enable_performance_insights = false
  db_performance_insights_retention_period = 7
  db_final_snapshot = false
  db_tags = var.db_tags
  
}
