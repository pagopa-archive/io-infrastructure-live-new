dependency "resource_group" {
  config_path = "../../resource_group"
}

# Subnet
dependency "subnet" {
  config_path = "../subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/pagopa/azurerm.git//jumpbox?ref=main"
}

inputs = {
  name = "io-p-vm-instabug"

  resource_group_name   = dependency.resource_group.outputs.resource_name
  location              = "westeurope"
  subnet_id             = dependency.subnet.outputs.id
  sku                   = "18.04-LTS"
  pip_allocation_method = "Static"
  size                  = "Standard_B1ls"

  remote_exec_inline_commands = [
    "sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl jq",
    "sudo apt-get update",
    "sudo apt-get install -y git",
  ]

  tags = { environment : "prod" }

}
