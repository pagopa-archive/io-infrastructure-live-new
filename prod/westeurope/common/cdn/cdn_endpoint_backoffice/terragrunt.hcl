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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cdn_endpoint?ref=v4.0.1"
}

inputs = {
  name                = "backoffice"
  resource_group_name = dependency.resource_group.outputs.resource_name
  profile_name        = dependency.cdn_profile.outputs.resource_name
  origin_host_name    = dependency.storage_account_backoffice.outputs.primary_web_host

  is_http_allowed = true

  global_delivery_rule = {

    cache_expiration_action       = []
    cache_key_query_string_action = []
    modify_request_header_action  = []

    modify_response_header_action = [{
      action = "Overwrite"
      name   = "Strict-Transport-Security"
      value  = "max-age=31536000"
      },
      {
        action = "Overwrite"
        name   = "Content-Security-Policy"
        value  = "default-src 'self'; connect-src https://api.io.italia.it https://iobackoffice.b2clogin.com; script-src 'self' 'unsafe-eval'; "
      },
      {
        action = "Append"
        name   = "Content-Security-Policy"
        value  = "frame-ancestors: 'self';"
      }
    ]

  }

  global_delivery_rule_cache_expiration_action = {
    behavior = "Override"
    duration = "00:00:05"
  }

  delivery_rule_url_path_condition_cache_expiration_action = [
    {
      # ATTENTION: this is rule is goind to fail due to this issue:
      # https://github.com/terraform-providers/terraform-provider-azurerm/issues/8770
      # so far has been applied with this fix:
      # https://github.com/terraform-providers/terraform-provider-azurerm/pull/9560/files within a custom provider.
      name         = "NoCache"
      order        = 2
      operator     = "Any"
      match_values = null
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
