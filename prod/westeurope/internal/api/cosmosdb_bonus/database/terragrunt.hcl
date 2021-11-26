dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "cosmosdb_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_sql_database?ref=v4.0.0"
}

inputs = {
  name                = "db"
  resource_group_name = dependency.resource_group.outputs.resource_name
  account_name        = dependency.cosmosdb_account.outputs.name
}
