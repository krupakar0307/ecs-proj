
resource "aws_iam_role" "secretsmanager_role" {
    name = "secretsmanager-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "secretsmanager.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy" "secretsmanager_policy" {
    name = "secretsmanager-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:CreateSecret",
                    "secretsmanager:PutSecretValue",
                    "secretsmanager:UpdateSecret"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "secretsmanager_attachment" {
    role       = aws_iam_role.secretsmanager_role.name
    policy_arn = aws_iam_policy.secretsmanager_policy.arn
}

resource "aws_secretsmanager_secret" "db_creds" {
    name = "dev/rds-creds/${aws_db_instance.rds_instance.identifier}"
}
