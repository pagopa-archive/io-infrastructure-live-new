dependency "subnet_fneucovidcert" {
  config_path = "../../eucovidcert/functions_eucovidcert/subnet"
}

dependency "subnet_cgn" {
  config_path = "../../cgn/functions_cgn/subnet"
}

dependency "subnet_cgn_merchant" {
  config_path = "../../cgn/functions_cgn_merchant/subnet"
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
  source = "git::https://github.com/pagopa/azurerm.git//nat_gateway?ref=v2.0.4"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_name
  name                = "io-p-natgw"
  subnet_ids = [
    dependency.subnet_fneucovidcert.outputs.id,
    dependency.subnet_cgn.outputs.id,
    dependency.subnet_cgn_merchant.outputs.id,
  ]
  location         = "westeurope"
  public_ips_count = 2
  tags             = { "environment" : "prod" }
}