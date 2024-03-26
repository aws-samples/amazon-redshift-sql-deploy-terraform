variable "region" {
  description = "The AWS region in which to create the Redshift cluster"
  type        = string
}

variable "cluster_identifier" {
  description = "The name of the Redshift cluster"
  type        = string
}

variable "node_type" {
  description = "The node type to be provisioned for the cluster"
  type        = string
}

variable "number_of_nodes" {
  description = "The number of compute nodes in the cluster"
  type        = number
}

variable "database_name" {
  description = "The name of the database to be created when the cluster is created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to associate with the cluster"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster"
  type        = list(string)
}

variable "run_nonrepeatable_queries" {
  description = "Whether to run non-repeatable queries"
  type        = bool
}

variable "run_repeatable_queries" {
  description = "Whether to run repeatable queries"
  type        = bool
}

variable "sql_path_bootstrap" {
  description = "The path to the SQL bootstrap file"
  type        = string
}

variable "sql_path_nonrepeatable" {
  description = "The path to the SQL non-repeatable file"
  type        = string
}

variable "sql_path_repeatable" {
  description = "The path to the SQL repeatable file"
  type        = string
}

variable "sql_path_finalize" {
  description = "The path to the SQL finalize file"
  type        = string
}

variable "create_random_password" {
  description = "Whether to create a random password"
  type        = bool
}

variable "master_username" {
  description = "The master username for the Redshift cluster"
  type        = string
}

variable "parameter_group_parameters" {
  description = "The parameters for the parameter group"
  type        = map(any)
}
