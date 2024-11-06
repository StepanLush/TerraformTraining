terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


resource "azurerm_resource_group" "attach_storage_task" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.attach_storage_task.location
  resource_group_name = azurerm_resource_group.attach_storage_task.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.attach_storage_task.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.attach_storage_task.location
  resource_group_name = azurerm_resource_group.attach_storage_task.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                          = "${var.prefix}-vm"
  location                      = azurerm_resource_group.attach_storage_task.location
  resource_group_name           = azurerm_resource_group.attach_storage_task.name
  network_interface_ids         = [azurerm_network_interface.main.id]
  vm_size                       = "Standard_B1ls"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"

  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}



resource "azurerm_managed_disk" "attach_storage_task" {
  name                 = "${var.prefix}-md1"
  location             = azurerm_resource_group.attach_storage_task.location
  resource_group_name  = azurerm_resource_group.attach_storage_task.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_storage_task" {
  managed_disk_id    = azurerm_managed_disk.attach_storage_task.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadWrite"
}




//Configure Terraform to Use Remote State
terraform {
  backend "azurerm" {
    resource_group_name  = "state-rg"
    storage_account_name = "ur6urur"
    container_name       = "stagecontainer"
    key                  = "terraform.tfstate"
  }
}
