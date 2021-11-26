dependency "api_management" {
  config_path = "../api_management"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_product?ref=update-azurerm-v2.87.0"
}

inputs = {
  product_id            = "io-mit-voucher"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  display_name          = "IO MIT VOUCHER"
  description           = "MIT VOUCHER for IO app."
  subscription_required = false
  approval_required     = false
  published             = false
}
