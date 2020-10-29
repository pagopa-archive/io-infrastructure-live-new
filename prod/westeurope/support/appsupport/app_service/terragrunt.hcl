dependency "subnet" {
  config_path = "../subnet"
}

# Support
dependency "resource_group" {
  config_path = "../../resource_group"
}

# External
dependency "subnet_appgateway" {
  config_path = "../../../external/appgateway/subnet"
}

dependency "app_service_pagopaproxytest" {
  config_path = "../../../external/pagopaproxytest/app_service"
}

# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

dependency "storage_account_logs" {
  config_path = "../../../operations/storage_account_logs/account"
}


/* #TODO storage account with table
dependency "storage_account" {
  config_path = "../../api/storage_notifications/account"
}
*/

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v2.1.5"

}

inputs = {
  name                = "support"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "Windows"
    sku_tier = "PremiumV2"
    sku_size = "P1V2"
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

    FETCH_KEEPALIVE_ENABLED = "true"
    // see https://github.com/MicrosoftDocs/azure-docs/issues/29600#issuecomment-607990556
    // and https://docs.microsoft.com/it-it/azure/app-service/app-service-web-nodejs-best-practices-and-troubleshoot-guide#scenarios-and-recommendationstroubleshooting
    // FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL should not exceed 120000 (app service socket timeout)
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL = "110000"
    // (FETCH_KEEPALIVE_MAX_SOCKETS * number_of_node_processes) should not exceed 160 (max sockets per VM)
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    # No downtime on slots swap
    # WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG = 1
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {

    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  /*
  allowed_subnets = [
    dependency.subnet_appgateway.outputs.id,
  ]
  */

  subnet_id = dependency.subnet.outputs.id

  application_logs = {
    key_vault_id             = dependency.key_vault.outputs.id
    key_vault_secret_sas_url = "logs-APPSUPPORT-SAS-URL"
    level                    = "Information"
    retention_in_days        = 90
  }
}
