dependency "resource_group" {
  config_path = "../../resource_group"
}

# Subnet
dependency "subnet" {
  config_path = "../subnet"
}

# Common
dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/pagopa/azurerm.git//jumpbox?ref=main"
}

inputs = {
  name = "io-p-vm-loadtest-gpc"

  resource_group_name   = dependency.resource_group.outputs.resource_name
  location              = "westeurope"
  subnet_id             = dependency.subnet.outputs.id
  sku                   = "18.04-LTS"
  pip_allocation_method = "Static"
  size                  = "Standard_D4s_v3"


  remote_exec_inline_commands = [
    "sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl",
    "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61",
    "sudo echo \"deb https://dl.bintray.com/loadimpact/deb stable main\" | tee -a /etc/apt/sources.list",
    "sudo apt-get update",
    "sudo apt-get install k6",
    "sudo apt-get install git",
  ]

  tags = { environment : "prod" }

}
