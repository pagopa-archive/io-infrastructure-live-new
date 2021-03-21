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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_product?ref=v3.0.0"
}

inputs = {
  product_id            = "io-public-api"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  display_name          = "IO PUBLIC API"
  description           = "PUBLIC API for IO platform."
  subscription_required = false
  approval_required     = false
  published             = true
}
