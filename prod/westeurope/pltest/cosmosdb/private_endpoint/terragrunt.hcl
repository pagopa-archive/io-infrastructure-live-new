# Private endpoint 
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "subnet_pendpoints" {
  config_path = "../../../common/subnet_private_endpoint"
}

dependency "cosmosdb_account" {
  config_path = "../../cosmosdb/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_endpoint?ref=172817813-add-private_ip_address-output-in-private-endpoint"
}

inputs = {
  name                = "endpoints-cosmosdb"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_pendpoints.outputs.id

  private_service_connection = {
    name                           = "endpoints-cosmosdb"
    private_connection_resource_id = dependency.cosmosdb_account.outputs.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
}
