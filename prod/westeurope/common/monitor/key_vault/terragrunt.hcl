dependency "key_vault" {
  config_path = "../../key_vault"
}

dependency "log_analytics_workspace" {
  config_path = "../../log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.25"
}

inputs = {

  name                       = "key-vault"
  target_resource_id         = dependency.key_vault.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "AuditEvent"
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
