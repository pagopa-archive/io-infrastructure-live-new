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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v2.1.7"
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
    WEBSITE_NODE_DEFAULT_VERSION   = "12.14.1"
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

    # TODO
    DASHBOARD_STORAGE_CONNECTION_STRING = dependency.storage_account.outputs.primary_connection_string
    DASHBOARD_LOGS_TABLE_NAME           = dependency.storage_table_backoffice.outputs.name

    #SLOT_TASK_HUBNAME = "ProductionTaskHub"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = []

  subnet_id = dependency.subnet.outputs.id
}
