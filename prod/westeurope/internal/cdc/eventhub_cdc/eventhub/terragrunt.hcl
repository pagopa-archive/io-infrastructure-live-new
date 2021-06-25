dependency "subnet" {
  config_path = "../subnet"
}

dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "cosmosdb_container_messages" {
  config_path = "../../../api/cosmosdb/container_messages"
}

# Common
dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/pagopa/azurerm.git//eventhub?ref=v1.0.19"
}

inputs = {


  name                     = "io-p-evh-cdc"
  location                 = "westeurope"
  resource_group_name      = dependency.resource_group.outputs.resource_name

  sku                      = "Standard"
  auto_inflate_enabled     = true
  maximum_throughput_units = 12

  virtual_network_id = dependency.virtual_network.outputs.id
  subnet_id          = dependency.subnet.outputs.id

  eventhubs = [
    {
      name              = "message-status"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "messages"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "notification-status"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "notifications"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "profiles"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "sender-services"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "services"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
    {
      name              = "user-data-processing"
      partitions        = 12
      message_retention = 3
      consumers         = []
      keys = [
        {
          name   = "io-functions-cdc"
          listen = false
          send   = true
          manage = false
        }
      ]
    },
  ]

  tags                = { "environment" : "prod" }
}
