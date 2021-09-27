# Common
dependency "resource_group" {
  config_path = "../resource_group"
}

dependency "subnet_azure_devops" {
  config_path = "../subnet_azure_devops"
}

dependency "virtual_network" {
  config_path = "../virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/azurerm.git//azure_devops_agent?ref=v1.0.51"
}

locals {
  commonvars  = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
}


inputs = {
  name = "io-p-azdoa-vmss-li"

  resource_group_name  = dependency.virtual_network.outputs.resource_group_name
  subnet_id            = dependency.subnet_azure_devops.outputs.id  
  subscription         = local.commonvars.locals.subscription
  tags                 = { "environment" : "prod" } # will be ignored anyway ¯\_(ツ)_/¯
}
