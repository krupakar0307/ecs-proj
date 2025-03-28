output "rds_endpoint" {
    value = "https://${aws_db_instance.rds_instance.endpoint}"
}
output "db_name" {
  value = aws_db_instance.rds_instance.db_name
}
output "db_username" {
  value = aws_db_instance.rds_instance.username
}
output "db_instance_arn" {
  value = aws_db_instance.rds_instance.arn
}
output "db_instance_type" {
  value = aws_db_instance.rds_instance.instance_class
 
}
output "db_instance_engine" {
  value = aws_db_instance.rds_instance.engine
}
output "db_instance_engine_version" {
  value = aws_db_instance.rds_instance.engine_version
}
