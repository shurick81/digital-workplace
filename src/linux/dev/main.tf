variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}
variable "VM_ADMIN_PASSWORD" {}

provider "azurerm" {
  version                       = "=2.6.0"
  subscription_id               = var.ARM_SUBSCRIPTION_ID
  client_id                     = var.ARM_CLIENT_ID
  client_secret                 = var.ARM_CLIENT_SECRET
  tenant_id                     = var.ARM_TENANT_ID
  features {}
}

resource "azurerm_resource_group" "common" {
  name     = "workplace-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "workplace-01-vm-dev-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.common.name
}

resource "azurerm_subnet" "main" {
  name                 = "mainSubnet"
  resource_group_name  = azurerm_resource_group.common.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_public_ip" "main" {
  name                = "workplace-01-vm-dev-pip"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.common.name
  allocation_method   = "Dynamic"
  domain_name_label   = "ipworkplace-01-vm-dev"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "main" {
  name                = "workplace-01-vm-dev-nsg"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.common.name

  security_rule {
    name                       = "SSH"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "main" {
  name                      = "workplace-01-vm-dev-nic01"
  location                  = "westeurope"
  resource_group_name       = azurerm_resource_group.common.name

  ip_configuration {
    name                          = "mainNicConfiguration"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id      = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.main.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "main" {
  name                          = "swazadmin00"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.common.name
  network_interface_ids         = [azurerm_network_interface.main.id]
  vm_size                       = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  #license_type                  = "Windows_Server"

  storage_os_disk {
    name              = "workplace-01-vm-dev-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202007290"
  }
 
  os_profile {
    computer_name  = "vm-dev"
    admin_username = "aleks"
    admin_password = var.VM_ADMIN_PASSWORD
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    inline = [
      "sudo apt -y update"
    ]
  }

  provisioner "file" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    source      = "../desktop.sh"
    destination = "/tmp/desktop.sh"
  }

  provisioner "remote-exec" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    inline = [
      "chmod +x /tmp/desktop.sh",
      "/tmp/desktop.sh",
    ]
  }

  provisioner "file" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    source      = "docker.sh"
    destination = "/tmp/docker.sh"
  }

  provisioner "remote-exec" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    inline = [
      "chmod +x /tmp/docker.sh",
      "/tmp/docker.sh",
    ]
  }

  provisioner "file" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    source      = "vscode.sh"
    destination = "/tmp/vscode.sh"
  }

  provisioner "remote-exec" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    inline = [
      "chmod +x /tmp/vscode.sh",
      "/tmp/vscode.sh",
    ]
  }

  provisioner "remote-exec" {
    connection {
      host     = "ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com"
      type     = "ssh"
      user     = "aleks"
      password = var.VM_ADMIN_PASSWORD
    }

    inline = [
      "sudo apt -y install git",
    ]
  }

}
