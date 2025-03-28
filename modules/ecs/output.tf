output "dns_name" {
  value = aws_lb.service_alb.dns_name
}
output "dns" {
  value = aws_route53_record.service_alb.fqdn
}
output "ecs_task_execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}
