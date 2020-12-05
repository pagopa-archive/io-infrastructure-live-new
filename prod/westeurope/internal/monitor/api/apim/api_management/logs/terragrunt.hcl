dependency "api_management" {
  config_path = "../../../../../api/apim/api_management"
}

dependency "storage_account_logs" {
  config_path = "../../../../../../operations/storage_account_logs/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.1.0"
}

inputs = {
  name               = "apim-api-logs"
  target_resource_id = dependency.api_management.outputs.id
  storage_account_id = dependency.storage_account_logs.outputs.id

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
    enabled  = false
    retention_policy = {
      days    = null
      enabled = false
    }
    },
    {
      category = "Capacity"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "EventHub Events"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "Network Status"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    }
  ]
}
