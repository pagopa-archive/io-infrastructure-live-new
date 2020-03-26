dependency "resource_group" {
  config_path = "../../resource_group"
}

// Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v0.0.29"
}

inputs = {
  name                = "apigad"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "Windows"
    sku_tier = "PremiumV2"
    sku_size = "P3v2"
  }

  app_enabled         = true
  client_cert_enabled = true
  https_only          = true

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    GAD_PROXY_CHANGE_ORIGIN      = "true"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      GAD_CA_CERTIFICATE_BASE64              = "apigad-GAD-CA-CERTIFICATE-BASE64"
      GAD_CLIENT_CERTIFICATE_VERIFIED_HEADER = "apigad-GAD-CLIENT-CERTIFICATE-VERIFIED-HEADER"
      GAD_PROXY_TARGET                       = "apigad-GAD-PROXY-TARGET"
    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  virtual_network_info = {
    name                  = dependency.virtual_network.outputs.resource_name
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    subnet_address_prefix = "10.0.1.0/24"
  }
}
