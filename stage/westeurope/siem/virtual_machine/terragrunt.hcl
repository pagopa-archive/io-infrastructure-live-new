dependency "resource_group_siem" {
  config_path = "../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "subnet_siem" {
  config_path = "../subnet"

  mock_outputs = {
    reosurce_name       = "fixture"
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_linux_virtual_machine?ref=v0.0.22"
}

inputs = {
  resource_group_name   = dependency.resource_group_siem.outputs.resource_name
  name                  = "vlog"

  size                  = "Standard_D4_v2"
  #subnet_id            =  dependency.subnet_siem.outputs.id
  subnet_id             = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-s-rg-siem/providers/Microsoft.Network/virtualNetworks/io-s-vnet-siem/subnets/siem"
  computer_name         = "Log Collector"
  admin_username        = "adminuser"

  source_image_reference = [{
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
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
    public_key = file("./id_rsa.pub")
  }]

  security_rules = [{
    name                          = "SSH"
    description                   = "Inbound ssh"
    priority                      = 1001
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_ranges            = ["0-65535"]
    destination_port_ranges       = [22]
    source_address_prefixes       = ["0.0.0.0/0"]
    destination_address_prefixes  = ["0.0.0.0/0"]
  }]
}
