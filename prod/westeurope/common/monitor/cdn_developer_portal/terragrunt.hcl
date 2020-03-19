dependency "log_analytics_workspace" {
  config_path = "../../../common/log_analytics_workspace"
}

dependency "storage_account" {
  config_path = "../../storage_account_logs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.47"
}

inputs = {

  name                       = "cdnendpoint-developerportal"
  # Note: this resource is not in this infrastructure project therefore we use the id instead of the dependency 
  target_resource_id         = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-p-rg-common/providers/Microsoft.Cdn/profiles/io-p-cdn-common/endpoints/io-p-cdnendpoint-developerportal"
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  storage_account_id = dependency.storage_account.outputs.id

  logs = [{
    category = "CoreAnalytics"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
  }]
}
