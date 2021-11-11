# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_plan?ref=v4.0.1"
}

inputs = {
  # This plan was previously shared with the appbackend which has been replaced within the cash back.
  name                = "appappbackend"
  resource_group_name = dependency.resource_group.outputs.resource_name

  kind     = "Windows"
  sku_tier = "PremiumV2"
  sku_size = "P1v2"
}
