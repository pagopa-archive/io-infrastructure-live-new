dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "storage_account_dashboard" {
  config_path = "../storage_account_dashboard"
}

# Common
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## Note this endpoint shouldn't be used anymore.
#  Use instead: cdn_endpoint_fnassets

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v2.1.7"
}

inputs = {
  name                = "dashboard"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_dashboard.outputs.primary_web_host

  global_delivery_rule_cache_expiration_action = {
    behavior = "Override"
    duration = "08:00:00"
  }

  /* #TODO: do we need to cache some content?
  delivery_rule_url_path_condition_cache_expiration_action = [
    {
      name         = "servicesdatacache"
      order        = 1
      operator     = "BeginsWith"
      match_values = ["/services-data"]
      behavior     = "Override"
      duration     = "00:15:00"
    },
    {
      name         = "bonuscache"
      order        = 2
      operator     = "BeginsWith"
      match_values = ["/bonus"]
      behavior     = "Override"
      duration     = "00:15:00"
    },
    {
      name         = "statuscache"
      order        = 3
      operator     = "BeginsWith"
      match_values = ["/status"]
      behavior     = "Override"
      duration     = "00:05:00"
    }
  ]
  */
}
