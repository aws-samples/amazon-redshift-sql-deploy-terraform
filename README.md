# Terraform Execute Redshift SQL

This repository contains Terraform code to provision and manage a Redshift cluster and execute SQL scripts on it.

## Prerequisites

Before you can use this Terraform code, make sure you have the following prerequisites installed:

- Terraform version 1.6.2 and up 
- AWS Command Line Interface (CLI)
- An AWS CLI profile configured with Redshift read/write permissions. 
- Python3
- Boto3

## Deploy the Solution

Sample code to deploy a Redshift cluster and database, along with UDFs, tables, views, and stored-procedure is provided in the Code repository section below. Follow these steps to deploy the solution:

1. Clone the git repo to your workspace:

    ```bash
    git clone https://gitlab.aws.dev/sylviqi/terraform-execute-redshift-sql
    ```

2. There are some sample SQL queries in the `src/redshift` folder. You may want to replace them with your own SQL queries. It is important to organize them in the appropriate folders so they can be executed in the correct sequence. See “Folder Structure for SQL Queries” for information on how to organize the SQL queries. 

3. Update the parameters in the `terraform.tfvars` file 

4. Deploy the resources using Terraform:

    ```bash
    cd terraform-execute-redshift-sql
    terraform init
    terraform plan -var-file terraform.tfvars
    terraform apply -var-file terraform.tfvars
    ```

## Folder Structure for SQL Queries

During Redshift cluster deployment, Terraform will execute the queries in the following order:

- /bootstrap
- /nonrepeatable
- /repeatable
- /finalize
