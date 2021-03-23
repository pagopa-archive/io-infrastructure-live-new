# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "app_service_plan" {
  config_path = "../app_service_plan"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v3.0.3"
}

inputs = {
  name                = "inpsproxy"
  resource_group_name = dependency.resource_group.outputs.resource_name
  app_service_plan_id = dependency.app_service_plan.outputs.id


  app_enabled         = true
  client_cert_enabled = false
  https_only          = false

  #application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
  application_insights_instrumentation_key = null

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"

    LOG_LEVEL = "debug"

    PROXY_CHANGE_ORIGIN   = "true"
    PROXY_TARGET_HOST     = "api.inps.it"
    PROXY_TARGET_PORT     = 443
    PROXY_TARGET_PROTOCOL = "https:"

  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      CLIENT_CERTIFICATE_CRT     = "io-INPS-BONUS-CERT"
      CLIENT_CERTIFICATE_KEY     = "io-INPS-BONUS-KEY"
      PROXY_AUTHENTICATION_TOKEN = "io-INPS-PROXY-TOKEN"
    }
  }

}
