dependency "cosmosdb_account" {
  config_path = "../account"
}

dependency "cosmosdb_database" {
  config_path = "../database"
}

#Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_sql_container?ref=v3.0.3"
}

inputs = {
  name                = "notification-status"
  resource_group_name = dependency.resource_group.outputs.resource_name
  account_name        = dependency.cosmosdb_account.outputs.name
  database_name       = dependency.cosmosdb_database.outputs.name
  partition_key_path  = "/notificationId"

  autoscale_settings = {
    max_throughput = 7000
  }
}
