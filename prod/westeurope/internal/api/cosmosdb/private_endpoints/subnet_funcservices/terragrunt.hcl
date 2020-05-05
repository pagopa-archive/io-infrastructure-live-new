# Internal
dependency "resource_group" {
  config_path = "../../../../resource_group"
}

dependency "subnet_func_services" {
  config_path = "../../../functions_services/subnet"
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
  name                = "endpoint-funcservices"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_func_services.outputs.id

  private_service_connection = {
    name                           = "private-funcservices"
    private_connection_resource_id = dependency.cosmosdb_account.outputs.id
    is_manual_connection           = false
    subresource_names              = null
  }

}
