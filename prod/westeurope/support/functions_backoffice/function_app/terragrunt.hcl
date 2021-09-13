dependency "subnet" {
  config_path = "../subnet"
}

# Support
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "storage_account" {
  config_path = "../../storage_backoffice/account"
}

dependency "redis" {
  config_path = "../../redis/redis_cache"
}

dependency "storage_table_backoffice" {
  config_path = "../../storage_backoffice/table_dashboardlog"
}

# common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "cdn_endpoint_custom_domain" {
  config_path = "../../../common/cdn/cdn_endpoint_backoffice_custom_domain"
}

# internal
dependency "subnet_apimapi" {
  config_path = "../../../internal/api/apim/subnet/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.3"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                = "backoffice"
  resource_group_name = dependency.resource_group.outputs.resource_name

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "Standard"
    sku_size = "S1"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    DASHBOARD_STORAGE_CONNECTION_STRING = dependency.storage_account.outputs.primary_connection_string
    DASHBOARD_LOGS_TABLE_NAME           = dependency.storage_table_backoffice.outputs.name

    # milliseconds
    IN_MEMORY_CACHE_TTL = 3600000

    ADB2C_ADMIN_GROUP_NAME = "Admin"

    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = "1"

    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key

    // CSTAR
    CSTAR_API_URL       = "https://api.cstar.pagopa.it"
    CSTAR_API_BASE_PATH = "backoffice"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {

      # PostgreSQL database connection
      POSTGRES_HOSTNAME = "cs-POSTGRES-HOSTNAME"
      POSTGRES_PORT     = "cs-POSTGRES-PORT"
      POSTGRES_USERNAME = "cs-POSTGRES-USERNAME"
      POSTGRES_PASSWORD = "cs-POSTGRES-PASSWORD"
      POSTGRES_DB_NAME  = "cs-POSTGRES-DB-NAME"
      POSTGRES_SCHEMA   = "cs-POSTGRES-SCHEMA"

      # AD B2C support
      JWT_SUPPORT_TOKEN_PUBLIC_RSA_CERTIFICATE = "bo-JWT-SUPPORT-TOKEN-PUBLIC-RSA-CERTIFICATE"
      ADB2C_CLIENT_ID                          = "bo-CLIENT-ID"
      ADB2C_POLICY_NAME                        = "bo-POLICY-NAME"
      ADB2C_TENANT_NAME                        = "bo-TENANT-NAME"

      ADB2C_CLIENT_KEY = "bo-CLIENT-KEY"
      ADB2C_TENANT_ID  = "bo-TENANT-ID"

      CSTAR_SUBSCRIPTION_KEY = "bo-CSTAR-SUBSCRIPTION-KEY"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id

}
