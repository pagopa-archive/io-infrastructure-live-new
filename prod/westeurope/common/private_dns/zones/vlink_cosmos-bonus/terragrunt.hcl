# VNET link 
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "virtual_network" {
  config_path = "../../../virtual_network"
}

dependency "private_dns_zone" {
  config_path = "../cosmosdb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_dns_zone_virtual_network_link?ref=v2.0.24"
}

inputs = {
  name                  = "virtual_network_link"
  private_dns_zone_name = "privatelink.documents.azure.com"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  virtual_network_id    = dependency.virtual_network.outputs.id
}
