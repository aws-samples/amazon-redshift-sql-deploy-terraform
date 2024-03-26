data "aws_secretsmanager_secret" "redshift_admin_secret" {
  name = module.secrets_manager_redshift_master_user.secret_arn
}

data "aws_secretsmanager_secret_version" "redshift_admin_secret_version" {
  secret_id = data.aws_secretsmanager_secret.redshift_admin_secret.id
}

data "aws_availability_zones" "available" {}
