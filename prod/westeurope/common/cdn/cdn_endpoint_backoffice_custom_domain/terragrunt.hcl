dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "cdn_endpoint_backoffice" {
  config_path = "../cdn_endpoint_backoffice"
}

# Common
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "dns_zone" {
  config_path = "../../../infra/public_dns_zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint_custom_domain?ref=v4.0.0"
}

inputs = {
  name                = "backoffice"
  resource_group_name = dependency.resource_group.outputs.resource_name
  dns_zone = {
    name                = dependency.dns_zone.outputs.name
    resource_group_name = dependency.dns_zone.outputs.resource_group_name
  }
  profile_name = dependency.cdn_profile.outputs.resource_name
  endpoint = {
    name     = dependency.cdn_endpoint_backoffice.outputs.resource_name
    hostname = dependency.cdn_endpoint_backoffice.outputs.hostname
  }
}
