# Common
dependency "virtual_network" {
  config_path = "../virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=v4.0.0"
}

inputs = {
  name = "pendpoints"

  resource_group_name  = dependency.virtual_network.outputs.resource_group_name
  virtual_network_name = dependency.virtual_network.outputs.resource_name
  address_prefix       = "10.0.240.0/23"

  enforce_private_link_endpoint_network_policies = true
}
