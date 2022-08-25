terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.77.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "East US"
}

resource "azurerm_resource_group" "rg" {
  name     = "k8sthw-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "kubernetesTHW-vn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "kubernetes"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicIp" {
  name                = "kubernetesTHW-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "vmIps" {
  count               = 6
  name                = "kubernetesTHW${count.index}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name = "kuberneteTHW-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location 
}

resource "azurerm_network_interface" "nics" {
  count = 6
  name = "nic-${count.index}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name      = "internal"
    primary   = true
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.${count.index+16}"
    public_ip_address_id = azurerm_public_ip.vmIps[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsgApplied" {
  count = 6
  network_security_group_id = azurerm_network_security_group.nsg.id
  network_interface_id = azurerm_network_interface.nics[count.index].id
}

resource "azurerm_linux_virtual_machine" "controllers" {
  count               = 3
  name                = "controller-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.nics[count.index].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") //TODO: Parameterize this
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_linux_virtual_machine" "workers" {
  count               = 3
  name                = "worker-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.nics[count.index+3].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") //TODO: Parameterize this
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}