dependency "api_management" {
  config_path = "../../../../api/apim/api_management"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../../common/log_analytics_workspace"
}

dependency "storage_account_logs" {
  config_path = "../../../../../operations/storage_account_logs"
}

dependency "resource_group_siem" {
  config_path = "../../../../../siem/resource_group"
}

dependency "event_hub_siem" {
  config_path = "../../../../../siem/event_hub"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.2"
}

inputs = {
  name                         = "apim-api"
  target_resource_id           = dependency.api_management.outputs.id
  log_analytics_workspace_id   = dependency.log_analytics_workspace.outputs.id
  storage_account_id           = dependency.storage_account_logs.outputs.id
  eventhub_name                = dependency.event_hub_siem.outputs.name[1]
  eventhub_namespace_name      = dependency.event_hub_siem.outputs.eventhub_namespace_name
  eventhub_authorization_rule  = "RootManageSharedAccessKey"
  eventhub_resource_group_name = dependency.resource_group_siem.outputs.resource_name

  logs = [{
    category = "GatewayLogs"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
  }]

  metrics = [{
    category = "Gateway Requests"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = false
    }
    },
    {
      category = "Capacity"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
    },
    {
      category = "EventHub Events"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
    },
    {
      category = "Network Status"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
    }
  ]
}
