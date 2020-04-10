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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_eventhub?ref=v2.0.2"
}

inputs = {
  namespce_name       = "siem"
  resource_group_name = dependency.resource_group_siem.outputs.resource_name
  sku                 = "Standard"

  eventhubs = [
    {
      name              = "io-p-evh-siem"
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
      /* this is not used anymore but can't be removed since it will recreate the other ruled which are in use */
      name          = "io-prod-ehr-true"
      eventhub_name = "io-p-evh-siem"
      listen        = true
      send          = false
      manage        = false
    },
    {
      name          = "io-prod-ehr-logs"
      eventhub_name = "io-p-evh-siem-logs"
      listen        = true
      send          = false
      manage        = false
    },
    {
      name          = "io-prod-ehr-monitor"
      eventhub_name = "io-p-evh-siem"
      listen        = true
      send          = false
      manage        = false
    }
  ]
}
