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
  name     = "workplace-00"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "workplace-00-vm-dev-vnet"
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
  name                = "workplace-00-vm-dev-pip"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.common.name
  allocation_method   = "Dynamic"
  domain_name_label   = "ipworkplace-00-vm-dev"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "main" {
  name                = "workplace-00-vm-dev-nsg"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.common.name

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
  name                      = "workplace-00-vm-dev-nic01"
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
  name                          = "swazwp00dev00"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.common.name
  network_interface_ids         = [azurerm_network_interface.main.id]
  vm_size                       = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  #license_type                  = "Windows_Server"

  storage_os_disk {
    name              = "workplace-00-vm-dev-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h1-pro"
    version   = "latest"
  }
 
  os_profile {
    computer_name  = "vm-dev"
    admin_username = "01qowieuth"
    admin_password = var.VM_ADMIN_PASSWORD
  }

  os_profile_windows_config {
    provision_vm_agent = true
    
    additional_unattend_config {
        pass = "oobeSystem"
        component = "Microsoft-Windows-Shell-Setup"
        setting_name = "AutoLogon"
        content = "<AutoLogon><Password><Value>${var.VM_ADMIN_PASSWORD}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>01sodfin</Username></AutoLogon>"
    }

    additional_unattend_config {
        pass = "oobeSystem"
        component = "Microsoft-Windows-Shell-Setup"
        setting_name = "FirstLogonCommands"
        content = file("./FirstLogonCommands.xml")
    }

  }

}
