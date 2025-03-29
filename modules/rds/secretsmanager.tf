
resource "aws_secretsmanager_secret_version" "db_creds_version" {
    secret_id = aws_secretsmanager_secret.db_creds.id
    secret_string = jsonencode({
        db_host = split(":", aws_db_instance.rds_instance.endpoint)[0]
        db_user      = aws_db_instance.rds_instance.username
        db_pass      = random_password.rds_password.result
        db_name      = aws_db_instance.rds_instance.db_name
    })
}

resource "aws_secretsmanager_secret" "db_creds" {
    name = "dev/rds-creds/${aws_db_instance.rds_instance.identifier}"
}
