dependency "resource_group" {
  config_path = "../../resource_group"
}

# Internal
dependency "subnet_appbackend" {
  config_path = "../../../internal/appbackend/subnet"
}

# Pagopa
dependency "subnet_agpagopagateway" {
  config_path = "../../../pagopa/network/subnet_agpagopagateway"
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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v2.1.0"
}

inputs = {
  name                = "pagopaproxyprod"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "Windows"
    sku_tier = "PremiumV2"
    sku_size = "P1v2"
  }

  app_enabled = true
  // TODO: Enable client certificate
  client_cert_enabled = false
  https_only          = true

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"

    REDIS_DB_URL      = dependency.redis.outputs.hostname
    REDIS_DB_PORT     = dependency.redis.outputs.ssl_port
    REDIS_DB_PASSWORD = dependency.redis.outputs.primary_access_key
    REDIS_USE_CLUSTER = true
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      PAGOPA_HOST                = "pagopaproxyprod-PAGOPA-HOST"
      PAGOPA_PORT                = "pagopaproxyprod-PAGOPA-PORT"
      PAGOPA_PASSWORD            = "pagopaproxyprod-PAGOPA-PASSWORD"
      PAGOPA_ID_PSP              = "pagopaproxyprod-PAGOPA-ID-PSP"
      PAGOPA_ID_INT_PSP          = "pagopaproxyprod-PAGOPA-ID-INT-PSP"
      PAGOPA_ID_CANALE           = "pagopaproxyprod-PAGOPA-ID-CANALE"
      PAGOPA_ID_CANALE_PAGAMENTO = "pagopaproxyprod-PAGOPA-ID-CANALE-PAGAMENTO"
      PAGOPA_WS_URI              = "pagopaproxyprod-PAGOPA-WS-URI"
    }
  }

  allowed_ips = []

  allowed_subnets = [
    dependency.subnet_appbackend.outputs.id,
    dependency.subnet_agpagopagateway.outputs.id
  ]

  virtual_network_info = {
    name                  = dependency.virtual_network.outputs.resource_name
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    subnet_address_prefix = "10.0.2.0/25"
  }
}
