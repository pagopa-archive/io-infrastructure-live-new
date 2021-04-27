dependency "app_service" {
  config_path = "../../app_service"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v3.0.3"
}

inputs = {
  name               = "appbackendl1-logs"
  target_resource_id = dependency.app_service.outputs.id
  storage_account_id = dependency.storage_account_logs.outputs.id

  logs = [{
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
    },
    {
      category = "AppServiceConsoleLogs"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "AppServiceAppLogs"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "AppServiceFileAuditLogs"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "AppServiceAuditLogs"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
  }]

  metrics = [{
    category = "AllMetrics"
    enabled  = false
    retention_policy = {
      days    = null
      enabled = false
    }
  }]
}
