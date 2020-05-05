# Internal
dependency "resource_group" {
  config_path = "../../../../resource_group"
}

dependency "subnet_func_admin" {
  config_path = "../../../functions_admin/subnet"
}

dependency "cosmosdb_account" {
  config_path = "../../account"
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
  name                = "endpoint-funcadmin"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_func_admin.outputs.id

  private_service_connection = {
    name                           = "private-funcadmin"
    private_connection_resource_id = dependency.cosmosdb_account.outputs.id
    is_manual_connection           = false
    subresource_names              = null
  }

}
