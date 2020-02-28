dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "dns_zone" {
  config_path = "../../dns_zone"
}

dependency "cdn_profile" {
  config_path = "../profile"
}

dependency "endpoint_assets" {
  config_path = "../endpoint_assets"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint_custom_domain?ref=v0.0.24"
}

inputs = {
  name                = "assets"
  resource_group_name = dependency.resource_group.outputs.resource_name
  dns_zone = {
    name                = dependency.dns_zone.outputs.name
    resource_group_name = dependency.dns_zone.outputs.resource_group_name
  }
  profile_name = dependency.cdn_profile.outputs.resource_name
  endpoint = {
    name     = dependency.endpoint_assets.outputs.resource_name
    hostname = dependency.endpoint_assets.outputs.hostname
  }
}
