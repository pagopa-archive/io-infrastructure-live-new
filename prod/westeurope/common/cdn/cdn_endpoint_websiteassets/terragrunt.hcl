dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "storage_account_website_assets" {
  config_path = "../storage_account_websiteassets"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v3.0.0"
}

inputs = {
  name                = "websiteassets"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_website_assets.outputs.primary_web_host
}
