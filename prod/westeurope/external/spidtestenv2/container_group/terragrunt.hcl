dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_container_group?ref=v2.0.1"
}

inputs = {
  name                = "spidtestenv2"
  resource_group_name = dependency.resource_group.outputs.resource_name

  container = {
    name   = "spidtestenv2"
    image  = "italia/spid-testenv2:latest"
    cpu    = "1"
    memory = "1.5"
    ports = [
      {
        port     = 443
        protocol = "TCP"
      }
    ]
    commands = ["python", "spid-testenv.py", "-c", "/containershare/config.yml"]
  }

  dns_cname_record = {
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
  }
}
