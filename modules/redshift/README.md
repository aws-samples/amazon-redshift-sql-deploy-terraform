# AWS Redshift Terraform module

Terraform module which creates Redshift resources on AWS.

## Usage

The solution is built based on the [AWS Terraform Redshift Module](https://github.com/terraform-aws-modules/terraform-aws-redshift). In addition to provisioning a Redshift cluster and database, we enhanced the module to deploy any number of database resources via SQL queries once the database is provisioned, and then continuously monitor changes in the repeatable SQLs and apply those changes using Terraform. We achieve this by utilizing terraform_data resources (sql-queries.tf), which invoke a custom Python script (sql-queries.py) to execute SQLs using the Redshift ExecuteStatement API.

For usage examples, please refer to examples [here](https://github.com/terraform-aws-modules/terraform-aws-redshift/tree/master/examples). Set the following variables if you wish to run SQL queries:
```
variable "run_nonrepeatable_queries" {
  description = "Specify whether to run nonrepeatable sql queries. When set to true, Terraform will run sql queries in the folders indicated by sql_path_bootstrap, sql_path_nonrepeatable, sql_path_finalize. These queries will only be run once since they are nonrepeatable."
  type        = bool
  default     = false
}

variable "run_repeatable_queries" {
  description = "Specify whether to run repeatable sql queries. When set to true, Terraform will run all sql queries in the folder indicated by sql_path_repeatable when a change is detected in the folder."
  type        = bool
  default     = false
}

variable "sql_path_bootstrap" {
  description = "Path to the bootstrap folder."
  type        = string
  default     = ""
}

variable "sql_path_nonrepeatable" {
  description = "Path to the nonrepeatable folder."
  type        = string
  default     = ""
}

variable "sql_path_repeatable" {
  description = "Path to the repeatable folder."
  type        = string
  default     = ""
}

variable "sql_path_finalize" {
  description = "Path to the finalize folder."
  type        = string
  default     = ""
}
```

## Folder Structure for SQL Queries

In order to use the module to execute Redshift SQL queries, you must organize your SQLs in a certain way. All SQLs must be stored in files with .sql extension. 

The SQLs are expected to be organized in the folder structure below. You can modify the code to work with any structure that fits your unique use case. 
```
/bootstrap
     |— Any # of files
     |— Any # of sub-folders
/nonrepeatable
     |— Any # of files 
     |— Any # of sub-folders
/repeatable
      /udf
          |— Any # of files 
          |— Any # of sub-folders
       /table
          |— Any # of files 
          |— Any # of sub-folders
      /view
          |— Any # of files 
          |— Any # of sub-folders
      /stored-procedure
          |— Any # of files 
          |— Any # of sub-folders 
/finalize
     |— Any # of files 
     |— Any # of sub-folders
```

Given the above folder structure, during Redshift cluster deployment, Terraform will execute the queries in the following order:

1. /bootstrap
2. /nonrepeatable
3. /repeatable
4. /finalize

If one of the queries fail, Terraform will execute them again until all the queries are successful. Once all the queries have been run successfully, Terraform will never execute them again on the same database, except for the SQLs in the /repeatable folder. The /repeatable folder comprises four sub-folders: /udf, /table, /view and /stored-procedure, indicating the order in which Terraform will execute the SQLs.

The terraform_data resource named “run_repeatable_queries” in sql-queries.tf monitors any changes in the repeatable folder using the SHA256 hash. If any file within the folder is updated, Terraform marks the entire directory for an update. 