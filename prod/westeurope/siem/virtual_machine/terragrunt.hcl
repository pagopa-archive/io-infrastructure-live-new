dependency "resource_group_siem" {
  config_path = "../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "subnet_siem" {
  config_path = "../subnet_siem"

  mock_outputs = {
    reosurce_name       = "fixture"
    resource_group_name = "fixture"
  }
}

dependency "key_vault_common" {
  config_path = "../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_linux_virtual_machine?ref=v0.0.39"
}

inputs = {
  resource_group_name   = dependency.resource_group_siem.outputs.resource_name
  name                  = "vlog"

  size                  = "Standard_D4_v2"
  subnet_id            =  dependency.subnet_siem.outputs.id
  computer_name         = "Log Collector"
  admin_username        = "adminuser"

  source_image_reference = [{
    publisher = "rsa-security-llc"
    offer     = "rsa-nw-suite-11-3"
    sku       = "rsa-nw-suite-11-3"
    version   = "11.3.0"
  }]

  os_disk = {
    name                        = "log-collector-disk"
    caching                     = "ReadWrite"
    storage_account_type        = "Standard_LRS"
    disk_size_gb                = "150"
    disk_encryption_set_id      = null
    write_accelerator_enabled  = false 
  }

  admin_ssh_key = [{
    username   = "adminuser"
    public_key = file("./mypubkey.pub")
  }]
  
  # This has been used for staging 
  #key_vault_id    = dependency.key_vault_common.outputs.id

  security_rules = [{
    name                          = "SSH"
    description                   = "Inbound ssh"
    priority                      = 1001
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_ranges            = ["*"]
    destination_port_ranges       = [22]
    source_address_prefixes       = ["0.0.0.0/0"]
    destination_address_prefixes  = ["0.0.0.0/0"]
  }]

  plans = [{
    name      = "rsa-nw-suite-11-3",
    product   = "rsa-nw-suite-11-3",
    publisher = "rsa-security-llc"
    plan      = "hourly"
  }]

}
