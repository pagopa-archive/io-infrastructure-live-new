## WARNING: deprecated. ##
## moved into https://github.com/pagopa/io-infra/blob/main/src/core/cgn.tf

dependency "cosmosdb_account" {
  config_path = "../account"
}

dependency "cosmosdb_database" {
  config_path = "../database"
}

#cgn
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_sql_container?ref=v4.0.0"
}

inputs = {
  name                = "cgn"
  resource_group_name = dependency.resource_group.outputs.resource_name
  account_name        = dependency.cosmosdb_account.outputs.name
  database_name       = dependency.cosmosdb_database.outputs.name
  partition_key_path  = "/id"
  throughput          = 400

  /**
  autoscale_settings = {
    max_throughput = 4000
  }
  */
}
