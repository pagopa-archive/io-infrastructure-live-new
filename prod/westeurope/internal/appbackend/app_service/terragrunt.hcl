dependency "resource_group" {
  config_path = "../../resource_group"
}

# Api
dependency "functions_app" {
  config_path = "../../api/functions_app/function_app"
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

dependency "redis" {
  config_path = "../../../common/redis/redis_cache"
}

dependency "notification_hub" {
  config_path = "../../../common/notification_hub"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v0.0.29"
}

inputs = {
  name                = "appbackend"
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
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"

    // ENVIRONMENT
    NODE_ENV = "production"

    // SPID
    SAML_CALLBACK_URL                      = "https://app-backend.io.italia.it/assertionConsumerService"
    SAML_LOGOUT_CALLBACK_URL               = "https://app-backend.io.italia.it/slo"
    SAML_ISSUER                            = "https://app-backend.io.italia.it"
    SAML_ATTRIBUTE_CONSUMING_SERVICE_INDEX = "0"
    SPID_VALIDATOR_URL                     = "https://validator.spid.gov.it"
    IDP_METADATA_URL                       = "https://registry.SPID.gov.it/metadata/idp/spid-entities-idps.xml"
    IDP_METADATA_REFRESH_INTERVAL_SECONDS  = "864000" # 10 days

    // CIE
    CIE_METADATA_URL = "https://idserver.servizicie.interno.gov.it:8443/idp/shibboleth"

    // AUTHENTICATION
    AUTHENTICATION_BASE_PATH  = ""
    TOKEN_DURATION_IN_SECONDS = "2592000"

    // FUNCTIONS
    API_URL       = "https://${dependency.functions_app.outputs.default_hostname}/api/v1"
    API_KEY       = dependency.functions_app.outputs.default_key

    // EXPOSED API
    API_BASE_PATH = "/api/v1"

    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key

    // PUSH NOTIFICATIONS
    ALLOW_NOTIFY_IP_SOURCE_RANGE : "0.0.0.0/0"
    AZURE_NH_HUB_NAME = dependency.notification_hub.outputs.name

    // PAGOPA
    ALLOW_PAGOPA_IP_SOURCE_RANGE : "0.0.0.0/0"
    // TODO: Fix the connection
    PAGOPA_API_URL      = "https://localhost"
    PAGOPA_API_URL_TEST = "https://localhost-test"
    PAGOPA_BASE_PATH    = "/pagopa/api/v1"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      // SPID
      SAML_CERT = "appbackend-SAML-CERT"
      SAML_KEY  = "appbackend-SAML-KEY"

      // PUSH NOTIFICATIONS
      PRE_SHARED_KEY    = "appbackend-PRE-SHARED-KEY"
      AZURE_NH_ENDPOINT = "common-AZURE-NH-ENDPOINT"
    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  allowed_subnets = []

  virtual_network_info = {
    name                  = dependency.virtual_network.outputs.resource_name
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    subnet_address_prefix = "10.0.100.0/25"
  }
}
