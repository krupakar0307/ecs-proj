data "aws_caller_identity" "current" {}

# IAM Policy for ECS to fetch secrets
resource "aws_iam_policy" "ecs_secrets_policy" {
  name        = "ecs-secrets-access-${var.service}"
  description = "Allows ECS tasks to retrieve secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          data.aws_secretsmanager_secret.db_secret.arn
        ]
      }
    ]
  })
}

# Attach IAM Policy to ECS Role
resource "aws_iam_role_policy_attachment" "ecs_secrets_policy_attachment" {
  role       = module.ecs.ecs_task_execution_role_name
  policy_arn = aws_iam_policy.ecs_secrets_policy.arn
}
