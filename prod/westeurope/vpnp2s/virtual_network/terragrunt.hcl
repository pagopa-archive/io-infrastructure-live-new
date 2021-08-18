dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network?ref=v3.0.3"
}

inputs = {
  name                = "vpnp2s"
  resource_group_name = dependency.resource_group.outputs.resource_name
  address_space       = ["10.1.0.0/16"]
}
