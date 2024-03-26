locals {
  program               = "${path.module}/sql-queries.py"
  redshift_cluster_name = try(aws_redshift_cluster.this[0].id, null)
}

resource "terraform_data" "run_bootstrap_queries" {
  count      = var.create && var.run_nonrepeatable_queries && (var.sql_path_bootstrap != "") && (var.snapshot_identifier == null) ? 1 : 0
  depends_on = [aws_redshift_cluster.this[0]]

  provisioner "local-exec" {
    command = "python3 ${local.program} ${var.sql_path_bootstrap} ${local.redshift_cluster_name} ${var.database_name} ${var.redshift_secret_arn} ${local.aws_region}"
  }
}

resource "terraform_data" "run_nonrepeatable_queries" {
  count      = var.create && var.run_nonrepeatable_queries && (var.sql_path_nonrepeatable != "") && (var.snapshot_identifier == null) ? 1 : 0
  depends_on = [terraform_data.run_bootstrap_queries]

  provisioner "local-exec" {
    command = "python3 ${local.program} ${var.sql_path_nonrepeatable} ${local.redshift_cluster_name} ${var.database_name} ${var.redshift_secret_arn} ${local.aws_region}"
  }
}

resource "terraform_data" "run_repeatable_queries" {
  count      = var.create && var.run_repeatable_queries && (var.sql_path_repeatable != "") ? 1 : 0
  depends_on = [terraform_data.run_nonrepeatable_queries]

  # Continuously monitor and apply changes in the repeatable folder
  triggers_replace = {
    dir_sha256 = sha256(join("", [for f in fileset("${var.sql_path_repeatable}", "**") : filesha256("${var.sql_path_repeatable}/${f}")]))
  }

  provisioner "local-exec" {
    command = "python3 ${local.program} ${var.sql_path_repeatable} ${local.redshift_cluster_name} ${var.database_name} ${var.redshift_secret_arn} ${local.aws_region}"
  }
}

resource "terraform_data" "run_finalize_queries" {
  count      = var.create && var.run_nonrepeatable_queries && (var.sql_path_finalize != "") && (var.snapshot_identifier == null) ? 1 : 0
  depends_on = [terraform_data.run_repeatable_queries]

  provisioner "local-exec" {
    command = "python3 ${local.program} ${var.sql_path_finalize} ${local.redshift_cluster_name} ${var.database_name} ${var.redshift_secret_arn} ${local.aws_region}"
  }
}
