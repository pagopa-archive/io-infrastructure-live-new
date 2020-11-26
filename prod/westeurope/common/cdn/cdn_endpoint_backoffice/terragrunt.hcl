dependency "cdn_profile" {
  config_path = "../cdn_profile"
}

dependency "storage_account_backoffice" {
  config_path = "../storage_account_backoffice"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v2.1.9"
}

inputs = {
  name                = "backoffice"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_backoffice.outputs.primary_web_host

  global_delivery_rule_cache_expiration_action = {
    behavior = "Override"
    duration = "08:00:00"
  }

  delivery_rule_url_path_condition_cache_expiration_action = [
    {
      name         = "NoCache"
      order        = 2
      operator     = "Any"
      match_values = ["/"]
      behavior     = "Override"
      duration     = "00:00:05"
    },
  ]

  delivery_rule_request_scheme_condition = [{
    name         = "EnforceHTTPS"
    order        = 1
    operator     = "Equal"
    match_values = ["HTTP"]

    url_redirect_action = {
      redirect_type = "Found"
      protocol      = "Https"
      hostname      = null
      path          = null
      fragment      = null
      query_string  = null
    }


  }]

}
