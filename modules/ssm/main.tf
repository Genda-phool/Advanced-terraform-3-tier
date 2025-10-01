resource "aws_ssm_parameter" "app_env" {
  name = "/${var.app_name}/APP_ENV"
  type = "String"
  value = "production"
}

resource "aws_ssm_parameter" "db_host" {
  name = "/${var.app_name}/DB_HOST"
  type = "String"
  value = var.db_host
}

resource "aws_ssm_parameter" "db_user" {
  name = "/${var.app_name}/DB_USER"
  type = "String"
  value = var.db_user
}

resource "aws_ssm_parameter" "db_pass" {
  name = "/${var.app_name}/DB_PASS"
  type = "SecureString"
  value = var.db_pass
}

output "ssm_prefix" { value = "/${var.app_name}" }
