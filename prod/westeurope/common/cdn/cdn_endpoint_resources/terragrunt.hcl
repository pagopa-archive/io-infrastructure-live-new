dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "storage_account_static_assets_iopay" {
  config_path = "../storage_account_resources"
}

# Common
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v2.1.15"
}

inputs = {
  name                = "resources"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_static_assets_iopay.outputs.primary_web_host
}
