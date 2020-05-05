# Internal
dependency "resource_group" {
  config_path = "../../../../resource_group"
}

dependency "subnet_func_app" {
  config_path = "../../../functions_app/subnet"
}

dependency "cosmosdb_account" {
  config_path = "../../../cosmosdb/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  # source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_endpoint?ref=v2.0.12"
  source = "../../../../../../../../io-infrastructure-modules-new/azurerm_private_endpoint"
}

inputs = {
  name                = "endpoint-funcapp"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_func_app.outputs.id

  private_service_connection = {
    name                           = "private-funcapp"
    private_connection_resource_id = dependency.cosmosdb_account.outputs.id
    is_manual_connection           = false
    subresource_names              = null
  }

}
