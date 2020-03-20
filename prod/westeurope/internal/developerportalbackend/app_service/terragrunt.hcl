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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v0.0.41"
}

inputs = {
  name                = "developerportalbackend"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "Windows"
    sku_tier = "PremiumV2"
    sku_size = "P1v2"
  }

  app_enabled         = true
  client_cert_enabled = false
  https_only          = false

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "6.11.2"
    WEBSITE_NPM_DEFAULT_VERSION  = "6.1.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    APIM_PRODUCT_NAME            = "io-services-api"
    APIM_USER_GROUPS             = "apilimitedmessagewrite,apiinforead,apimessageread,apilimitedprofileread"
    ARM_APIM                     = "io-p-apim-api"
    ARM_RESOURCE_GROUP           = "io-p-rg-external"
    USE_SERVICE_PRINCIPAL        = "1"
    CLIENT_NAME                  = "io-p-developer-portal-app"
    LOG_LEVEL                    = "info"
    POLICY_NAME                  = "B2C_1_SignUpIn"
    RESET_PASSWORD_POLICY_NAME   = "B2C_1_PasswordReset"
    POST_LOGIN_URL               = "https://developer.io.italia.it"
    POST_LOGOUT_URL              = "https://developer.io.italia.it"
    REPLY_URL                    = "https://developer.io.italia.it"
    ADMIN_API_URL                = "https://api.io.italia.it"
    TENANT_ID                    = "agidweb.onmicrosoft.com"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      admin-api-key               = "devportal-ADMIN-API-KEY"
      arm-subscription-id         = "devportal-ARM-SUBSCRIPTION-ID"
      arm-tenant-id               = "devportal-ARM-TENANT-ID"
      client-id                   = "devportal-CLIENT-ID" 
      client-secret               = "devportal-CLIENT-SECRET"
      cookie-iv                   = "devportal-COOKIE-IV"
      cookie-key                  = "devportal-COOKIE-KEY"
      service-principal-client-id = "devportal-SERVICE-PRINCIPAL-CLIENT-ID"
      service-principal-secret    = "devportal-SERVICE-PRINCIPAL-SECRET"
      service-principal-tenant-id = "devportal-SERVICE-PRINCIPAL-TENANT-ID"
    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  virtual_network_info = {
    name                  = dependency.virtual_network.outputs.resource_name
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    subnet_address_prefix = "10.0.106.0/24"
  }
}
