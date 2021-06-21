dependency "subnet_eucovidcert" {
  config_path = "../../eucovidcert/functions_eucovidcert/subnet"
}

# Common
dependency "resource_group" {
  config_path = "../resource_group"
}

terraform {
  source = "git::https://github.com/pagopa/azurerm.git//nat_gateway?ref=v1.0.7"
}
inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_name
  name                = "io-p-natgw"
  subnet_ids          = [dependency.subnet_eucovidcert.outputs.id]
  location            = "westeurope"
  tags                = { "environment" : "prod" }
}