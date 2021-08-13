dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "virtual_network" {
  config_path = "../../virtual_network"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_private_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_private_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_private" {
  config_path = "../../storage/account"
}

dependency "application_insights" {
  config_path = "../../application_insights"
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
  name                = "private"
  resource_group_name = dependency.resource_group.outputs.resource_name


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

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
  
  health_check_path = "api/v1/info"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    COSMOSDB_URI  = dependency.cosmosdb_private_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_private_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_private_database.outputs.name

    QueueStorageConnection = dependency.storage_private.outputs.primary_connection_string

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # DNS and VNET configuration to use private endpoint
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = 1

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-fn3-private"
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map = {
    }
  }

  # allowed_subnets = [
  #   dependency.subnet.outputs.id
  # ]

  # allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
