dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_account" {
  config_path = "../../storage/account"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_apimapi" {
  config_path = "../../../api/apim/subnet"
}

# Common
dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v4.0.0"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                = "public"
  resource_group_name = dependency.resource_group.outputs.resource_name

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  health_check_path = "info"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "14.16.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    # DNS and VNET configuration to use private endpoint
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = 1

    COSMOSDB_URI      = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY      = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME     = dependency.cosmosdb_database.outputs.name
    StorageConnection = dependency.storage_account.outputs.primary_connection_string

    VALIDATION_CALLBACK_URL = "https://api-app.io.pagopa.it/email_verification.html"

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # it is required due to this issue: https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    # at the time we applied these chages the value is the following.
    WEBSITE_CONTENTSHARE = "io-p-fn3-public-content"

  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
