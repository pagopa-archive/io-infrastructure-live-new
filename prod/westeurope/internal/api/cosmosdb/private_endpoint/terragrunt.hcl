dependency "cosmosdb_account" {
  config_path = "../account"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Common
dependency "subnet_pendpoints" {
  config_path = "../../../../common/subnet_pendpoints"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_endpoint?ref=v2.1.19"
}

inputs = {
  name                = "${dependency.cosmosdb_account.outputs.name}-sql-endpoint"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_pendpoints.outputs.id

  private_service_connection = {
    name                           = "${dependency.cosmosdb_account.outputs.name}-sql"
    private_connection_resource_id = dependency.cosmosdb_account.outputs.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
}
