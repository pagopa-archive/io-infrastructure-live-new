dependency "public_ip" {
  config_path = "../../../appgateway/public_ip"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.47"
}

inputs = {
  name                           = "pip-appgateway"
  target_resource_id             = dependency.public_ip.outputs.id
  log_analytics_workspace_id     = dependency.log_analytics_workspace.outputs.id
  # It might work with these fixed values due to this issue
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/6356
  eventhub_name                  = "io-p-evh-siem-logs"
  eventhub_authorization_rule_id = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-p-rg-siem/providers/Microsoft.EventHub/namespaces/io-p-evhns-siem/authorizationrules/RootManageSharedAccessKey"
  logs = [{
    category = "DDoSProtectionNotifications"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
    },
    {
      category = "DDoSMitigationFlowLogs"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    },
    {
      category = "DDoSMitigationReports"
      enabled  = false
      retention_policy = {
        days    = 0
        enabled = false
      }
  }]

  metrics = [{
    category = "AllMetrics"
    enabled  = false
    retention_policy = {
      days    = 0
      enabled = false
    }
  }]
}
