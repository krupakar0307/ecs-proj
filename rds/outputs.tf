output "rds_endpoint" {
    value = module.rds.rds_endpoint
}
output "db_name" {
  value = module.rds.db_name
}
output "db_username" {
  value = module.rds.db_username
}
output "db_instance_arn" {
  value = module.rds.db_instance_arn
}
output "db_instance_type" {
  value = module.rds.db_instance_type
 
}
output "db_instance_engine" {
  value = module.rds.db_instance_engine
}
output "db_instance_engine_version" {
  value = module.rds.db_instance_engine_version
}
