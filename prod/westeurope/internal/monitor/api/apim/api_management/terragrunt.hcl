dependency "api_management" {
  config_path = "../../../../api/apim/api_management"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../../common/log_analytics_workspace"
}

dependency "storage_account" {
  config_path = "../../../../../common/storage_account_logs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.47"
}

inputs = {
  name                       = "apim-api"
  target_resource_id         = dependency.api_management.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id
  storage_account_id         = dependency.storage_account.outputs.id

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
      enabled = true
    }
    },
    {
      category = "Capacity"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    },
    {
      category = "EventHub Events"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    },
    {
      category = "Network Status"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    }
  ]
}
