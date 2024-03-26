# update the values as per your requirement
region                    = "us-east-1"
cluster_identifier        = "test-cluster"
node_type                 = "ra3.xlplus"
number_of_nodes           = 1
database_name             = "db1"
subnet_ids                = ["subnet-02ec313c292dc3c35", "subnet-0acaa0f0e7d4966a6"]
vpc_security_group_ids    = ["sg-0d98c96a815656ab3"]
run_nonrepeatable_queries = true
run_repeatable_queries    = true
sql_path_bootstrap        = "src/redshift/bootstrap"
sql_path_nonrepeatable    = "src/redshift/nonrepeatable"
sql_path_repeatable       = "src/redshift/repeatable"
sql_path_finalize         = "src/redshift/finalize"
create_random_password    = false
master_username           = "admin"
parameter_group_parameters = {
  require_ssl = {
    name  = "require_ssl"
    value = true
  }
}
