dependency "app_service" {
  config_path = "../../../../pagopaproxyprod/app_service"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.12"
}

inputs = {
  name                       = "pagopaproxyprod-analytics"
  target_resource_id         = dependency.app_service.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy = {
      days    = null
      enabled = false
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
      enabled  = true
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
    enabled  = true
    retention_policy = {
      days    = null
      enabled = false
    }
  }]
}
