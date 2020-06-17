dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "storage_account_assets" {
  config_path = "../storage_account_assets"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v2.0.31"
}

inputs = {
  name                = "assets"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_assets.outputs.primary_web_host

  global_delivery_rule_cache_expiration_action = {
    behavior = "Override"
    duration = "08:00:00"
  }

  # Note: match_values = ["/services-data","/bonus"] works but the Azure portal displays only
  # the first item for each rule generating confusion on the actual set of rules applied 
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

}
