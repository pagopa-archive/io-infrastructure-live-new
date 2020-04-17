dependency "app_service" {
  config_path = "../../../appbackend/app_service"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../common/log_analytics_workspace"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.12"
}

inputs = {
  name                       = "appbackend"
  target_resource_id         = dependency.app_service.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id
  storage_account_id         = dependency.storage_account_logs.outputs.id

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
        days    = 365
        enabled = false
      }
    },
    {
      category = "AppServiceAppLogs"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
    },
    {
      category = "AppServiceFileAuditLogs"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
    },
    {
      category = "AppServiceAuditLogs"
      enabled  = false
      retention_policy = {
        days    = 365
        enabled = false
      }
  }]

  metrics = [{
    category = "AllMetrics"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = false
    }
  }]
}
