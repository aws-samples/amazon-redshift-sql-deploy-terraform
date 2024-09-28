module "redshift" {
  # checkov:skip=CKV_AWS_71: 'Logging option is availble in the module, its upto the user to enable it or not'
  # checkov:skip=CKV_AWS_105: 'AWS Redshift Cluster SSL is already enabled in parameter group'

  source = "./modules/redshift"

  cluster_identifier         = var.cluster_identifier
  node_type                  = var.node_type
  number_of_nodes            = var.number_of_nodes
  database_name              = var.database_name
  subnet_ids                 = var.subnet_ids
  vpc_security_group_ids     = var.vpc_security_group_ids
  run_nonrepeatable_queries  = var.run_nonrepeatable_queries
  run_repeatable_queries     = var.run_repeatable_queries
  sql_path_bootstrap         = var.sql_path_bootstrap
  sql_path_nonrepeatable     = var.sql_path_nonrepeatable
  sql_path_repeatable        = var.sql_path_repeatable
  sql_path_finalize          = var.sql_path_finalize
  create_random_password     = var.create_random_password
  master_username            = jsondecode(data.aws_secretsmanager_secret_version.redshift_admin_secret_version.secret_string)["username"]
  master_password            = jsondecode(data.aws_secretsmanager_secret_version.redshift_admin_secret_version.secret_string)["password"]
  redshift_secret_arn        = module.secrets_manager_redshift_master_user.secret_arn
  parameter_group_parameters = var.parameter_group_parameters
}

# Secret for Redshift master user
module "secrets_manager_redshift_master_user" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-secrets-manager.git?ref=6e549c20f5fe6f8b4f8c36499d1e2455ee3d695b"

  description             = "Redshift master user and password"
  name                    = "/redshift/master_user/password"
  recovery_window_in_days = 0

  secret_string = jsonencode({
    username = var.master_username
    password = random_password.redshift_master_password.result
  })
}

# Password generator
resource "random_password" "redshift_master_password" {
  length           = 16
  special          = true
  numeric          = true
  upper            = true
  lower            = true
  override_special = "!#$%&*()_=+[]{}"
}
