dependency "app_service" {
  config_path = "../app_service"
}

dependency "subnet" {
  config_path = "../subnet"
}

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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_slot?ref=v2.0.41"
}

inputs = {
  name                = "staging"
  resource_group_name = dependency.resource_group.outputs.resource_name
  app_service_id      = dependency.app_service.outputs.id
  app_service_name    = dependency.app_service.outputs.name
  app_service_plan_id = dependency.app_service.outputs.app_service_plan_id

  app_enabled         = true
  client_cert_enabled = false
  https_only          = true
  auto_swap_slot_name = "production"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    GAD_PROXY_CHANGE_ORIGIN      = "true"

    DISABLE_CLIENT_CERTIFICATE_VERIFICATION = "true"
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

  subnet_id = dependency.subnet.outputs.id
}
