dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "cdn_endpoint_developerportal" {
  config_path = "../cdn_endpoint_developerportal"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint_custom_domain?ref=v2.0.37"
}

inputs = {
  name                = "developer"
  resource_group_name = dependency.resource_group.outputs.resource_name
  dns_zone = {
    name                = "io.italia.it"
    resource_group_name = "io-infra-rg"
  }
  profile_name = dependency.cdn_profile.outputs.resource_name
  endpoint = {
    name     = dependency.cdn_endpoint_developerportal.outputs.resource_name
    hostname = dependency.cdn_endpoint_developerportal.outputs.hostname
  }
}
