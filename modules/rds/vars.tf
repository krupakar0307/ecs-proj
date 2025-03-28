variable "engine" {
  description = "The database engine to use. e.g., mysql, postgres"
  type        = string
  default     = "mysql"
  
}
variable engine_version {
  description = "The database engine version to use."
  type        = string
  default     = "8.0"
}
variable db_name {
  description = "The name of the database to create."
  type        = string
  default     = "wordpress"
}
variable db_username {
  description = "The username for the database."
  type        = string
  default     = "admin_user"
}
variable db_instance_class {
  description = "The instance class for the database."
  type        = string
  default     = "db.t3.micro"
}
variable db_allocated_storage {
  description = "The allocated storage for the database."
  type        = number
  default     = 20
}
variable db_storage_type {
  description = "The storage type for the database."
  type        = string
  default     = "gp2"
}
  
variable db_parameter_group_name {
  description = "The name of the DB parameter group."
  type        = string
  default     = "default.mysql8.0"
}

variable db_backup_retention_period {
  description = "The number of days to retain backups."
  type        = number
  default     = 7
}
variable db_multi_az {
  description = "Whether to create a Multi-AZ deployment."
  type        = bool
  default     = false
}

variable db_enable_performance_insights {
  description = "Whether to enable Performance Insights."
  type        = bool
  default     = false
}
variable db_performance_insights_retention_period {
  description = "The number of days to retain Performance Insights data."
  type        = number
  default     = 7
}

variable db_tags {
  description = "A map of tags to assign to the database."
  type        = map(string)
  default     = {
    Name        = "wordpress-db"
    Environment = "dev"
  }
}

variable db_final_snapshot {
  description = "Whether to create a final snapshot before deletion."
  type        = bool
  default     = true
}   
