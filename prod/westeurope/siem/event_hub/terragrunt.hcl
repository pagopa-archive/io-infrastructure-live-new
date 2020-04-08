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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_eventhub?ref=v0.0.27"
}

inputs = {
  name                = "siem"
  resource_group_name = dependency.resource_group_siem.outputs.resource_name
  partition_count     = 4
  message_retention   = 5
  sku                 = "Standard"

  eventhub_authorization_rules = [
    {
      listen = true
      send   = false
      manage = false
    }
  ]
}
