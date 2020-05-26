dependency "resource_group_common" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_key_vault?ref=v2.0.25"
}

inputs = {
  name                = "common"
  resource_group_name = dependency.resource_group_common.outputs.resource_name
}
