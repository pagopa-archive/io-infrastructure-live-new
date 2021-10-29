dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "function_app" {
  config_path = "../function_app"
}

# Notification Hubs
dependency "notification_hub" {
  config_path = "../../../common/notification_hub"
}

dependency "notification_hub_partition_1" {
  config_path = "../../../common/notification_hub_partition_1"
}

dependency "notification_hub_partition_2" {
  config_path = "../../../common/notification_hub_partition_2"
}

dependency "notification_hub_partition_3" {
  config_path = "../../../common/notification_hub_partition_3"
}

dependency "notification_hub_partition_4" {
  config_path = "../../../common/notification_hub_partition_4"
}

# Internal
dependency "storage_notifications" {
  config_path = "../../../internal/api/storage_notifications/account"
}

dependency "storage_notifications_queue_push-notifications" {
  config_path = "../../../internal/api/storage_notifications/queue_push-notifications"
}

# Beta test users storage
dependency "storage_beta_test_users" {
  config_path = "../../../internal/api/storage_beta_test_users/account"
}

dependency "storage_beta_test_users_table_notificationhub" {
  config_path = "../../../internal/api/storage_beta_test_users/table_notification_hub"
}

# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "subnet_azure_devops" {
  config_path = "../../../common/subnet_azure_devops"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  testusersvars = read_terragrunt_config(find_in_parent_folders("testusersvars.hcl"))
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v3.0.12"
}

inputs = {
  name                                               = "staging"
  resource_group_name                                = dependency.resource_group.outputs.resource_name
  function_app_name                                  = dependency.function_app.outputs.name
  function_app_resource_name                         = dependency.function_app.outputs.resource_name
  app_service_plan_id                                = dependency.function_app.outputs.app_service_plan_id
  storage_account_name                               = dependency.function_app.outputs.storage_account.name
  storage_account_access_key                         = dependency.function_app.outputs.storage_account.primary_access_key
  storage_account_durable_function_connection_string = dependency.function_app.outputs.storage_account_durable_function.primary_connection_string

  runtime_version = "~3"

  health_check_path = "api/v1/info"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "14.16.0"
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

    NOTIFICATIONS_QUEUE_NAME                = dependency.storage_notifications_queue_push-notifications.outputs.name
    NOTIFICATIONS_STORAGE_CONNECTION_STRING = dependency.storage_notifications.outputs.primary_connection_string

    FISCAL_CODE_NOTIFICATION_BLACKLIST = join(",", local.testusersvars.locals.test_users_internal_load)

    // activity default retry attempts
    RETRY_ATTEMPT_NUMBER = 10

    APPINSIGHTS_SAMPLING_PERCENTAGE = 5

    # ------------------------------------------------------------------------------
    # Notification Hubs variables

    # Endpoint for the test notification hub namespace
    AZURE_NH_HUB_NAME = dependency.notification_hub.outputs.name

    # Endpoint for the test notification hub namespace
    NH1_PARTITION_REGEX = "^[0-3]"
    NH1_NAME            = dependency.notification_hub_partition_1.outputs.name
    NH2_PARTITION_REGEX = "^[4-7]"
    NH2_NAME            = dependency.notification_hub_partition_2.outputs.name
    NH3_PARTITION_REGEX = "^[8-b]"
    NH3_NAME            = dependency.notification_hub_partition_3.outputs.name
    NH4_PARTITION_REGEX = "^[c-f]"
    NH4_NAME            = dependency.notification_hub_partition_4.outputs.name
    # ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # Variable used during transition to new NH management

    # Possible values : "none" | "all" | "beta" | "canary"
    NH_PARTITION_FEATURE_FLAG            = "all"
    BETA_USERS_STORAGE_CONNECTION_STRING = dependency.storage_beta_test_users.outputs.primary_connection_string
    BETA_USERS_TABLE_NAME                = dependency.storage_beta_test_users_table_notificationhub.outputs.name

    # Takes ~6,25% of users
    CANARY_USERS_REGEX = "^([(0-9)|(a-f)|(A-F)]{63}0)$"
    # ------------------------------------------------------------------------------

    // Disable functions
    "AzureWebJobs.HandleNHNotificationCall.Disabled" = "0"

    WEBSITE_PROACTIVE_AUTOHEAL_ENABLED = "True"
    # AzureFunctionsJobHost__extensions__durableTask__storageProvider__partitionCount = "16"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      AZURE_NH_ENDPOINT = "common-AZURE-NH-ENDPOINT"
      NH1_ENDPOINT      = "common-partition-1-AZURE-NH-ENDPOINT"
      NH2_ENDPOINT      = "common-partition-2-AZURE-NH-ENDPOINT"
      NH3_ENDPOINT      = "common-partition-3-AZURE-NH-ENDPOINT"
      NH4_ENDPOINT      = "common-partition-4-AZURE-NH-ENDPOINT"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_azure_devops.outputs.id,
  ]

  allowed_ips = []

  subnet_id       = dependency.subnet.outputs.id
  function_app_id = dependency.function_app.outputs.id
}
