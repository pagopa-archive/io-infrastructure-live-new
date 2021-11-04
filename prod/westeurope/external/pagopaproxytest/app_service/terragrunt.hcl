dependency "resource_group" {
  config_path = "../../resource_group"
}

# Linux
dependency "subnet_appbackendl1" {
  config_path = "../../../linux/appbackendl1/subnet/"
}

dependency "subnet_appbackendl2" {
  config_path = "../../../linux/appbackendl2/subnet/"
}

# iopayportal
dependency "subnet_fniopayportal" {
  config_path = "../../../internal/api/functions_iopayportal/subnet"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v3.0.3"
}

inputs = {
  name                = "pagopaproxytest"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind             = "Windows"
    sku_tier         = "Standard"
    sku_size         = "S1"
    per_site_scaling = false
    reserved         = false
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
    NM3_ENABLED       = true
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      PAGOPA_HOST                = "pagopaproxytest-PAGOPA-HOST"
      PAGOPA_PORT                = "pagopaproxytest-PAGOPA-PORT"
      PAGOPA_CERT                = "pagopaproxytest-PAGOPA-CERT"
      PAGOPA_KEY                 = "pagopaproxytest-PAGOPA-KEY"
      PAGOPA_PASSWORD            = "pagopaproxytest-PAGOPA-PASSWORD"
      PAGOPA_ID_PSP              = "pagopaproxytest-PAGOPA-ID-PSP"
      PAGOPA_ID_INT_PSP          = "pagopaproxytest-PAGOPA-ID-INT-PSP"
      PAGOPA_ID_CANALE           = "pagopaproxytest-PAGOPA-ID-CANALE"
      PAGOPA_ID_CANALE_PAGAMENTO = "pagopaproxytest-PAGOPA-ID-CANALE-PAGAMENTO"
      PAGOPA_WS_URI              = "pagopaproxytest-PAGOPA-WS-URI"
    }
  }

  allowed_ips = []

  allowed_ips_secret = {
    key_vault_id     = dependency.key_vault.outputs.id
    key_vault_secret = "pagopaproxytest-ALLOWED-IPS"
  }

  allowed_subnets = [
    dependency.subnet_appbackendl1.outputs.id,
    dependency.subnet_appbackendl2.outputs.id,
    dependency.subnet_fniopayportal.outputs.id,
  ]
  virtual_network_info = {
    name                  = dependency.virtual_network.outputs.resource_name
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    subnet_address_prefix = "10.0.2.128/25"
  }
}
