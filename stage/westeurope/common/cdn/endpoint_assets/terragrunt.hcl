dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "cdn_profile" {
  config_path = "../profile"
}

dependency "storage_account_assets" {
  config_path = "../storage_account_assets"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v0.0.24"
}

inputs = {
  name                = "assets"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_assets.outputs.primary_blob_host
}
