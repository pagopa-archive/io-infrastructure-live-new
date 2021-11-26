// External
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_public_ip?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                = "appgateway"
  resource_group_name = dependency.resource_group.outputs.resource_name
  sku                 = "Standard"
  allocation_method   = "Static"
}
