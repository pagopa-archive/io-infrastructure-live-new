dependency "resource_group_siem" {
  config_path = "../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_eventhub?ref=v2.0.25"
}

inputs = {
  namespace_name      = "siem"
  resource_group_name = dependency.resource_group_siem.outputs.resource_name
  sku                 = "Standard"

  eventhubs = [
    {
      name              = "io-p-evh-siem-monitor"
      partition_count   = 4
      message_retention = 5
    },
    {
      name              = "io-p-evh-siem-logs"
      partition_count   = 4
      message_retention = 5
    },
  ]

  eventhub_authorization_rules = [
    {
      name          = "io-prod-ehr-logs"
      eventhub_name = "io-p-evh-siem-logs"
      listen        = true
      send          = false
      manage        = false
    },
    {
      name          = "io-prod-ehr-monitor"
      eventhub_name = "io-p-evh-siem-monitor"
      listen        = true
      send          = false
      manage        = false
    }
  ]
}
