
# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.service}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
data "aws_caller_identity" "current" {}

# IAM Policy for ECS to fetch secrets
resource "aws_iam_policy" "ecs_cloudwatch_policy" {
  name        = "ecs-cloudwatch-${var.service}"
  description = "Allows ECS tasks to retrieve secrets from AWS cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ]
        Resource = [
        #   data.aws_secretsmanager_secret.db_secret.arn,
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/*"
          
        ]
      }
    ]
  })
}

# Attach IAM Policy to ECS Role
resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_policy.arn
}