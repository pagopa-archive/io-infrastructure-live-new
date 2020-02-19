dependency "resource_group_spid" {
  config_path = "../resource_group"
}

dependency "dns_zone_common" {
  config_path = "../../common/dns_zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_container_group?ref=v0.0.15"
}

inputs = {
  name                = "spid-testenv2"
  resource_group_name = dependency.resource_group_spid.outputs.resource_name

  container = {
    name   = "spid-testenv2"
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
    zone_name = dependency.dns_zone_common.outputs.name
    zone_resource_group_name = dependency.dns_zone_common.outputs.resource_group_name
  }
}
