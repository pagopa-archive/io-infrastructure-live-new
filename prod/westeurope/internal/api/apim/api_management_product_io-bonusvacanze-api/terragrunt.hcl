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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_product?ref=v2.0.25"
}

inputs = {
  product_id            = "io-bonusvacanze-api"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  display_name          = "IO BONUS VACANZE API"
  description           = "BONUS VACANZE API for IO platform."
  subscription_required = true
  approval_required     = false
  published             = true
  policy_xml            = file("policy.xml")
}
