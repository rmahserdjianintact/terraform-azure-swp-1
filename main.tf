terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # http://terraform.io/docs/providers/azurerm/index.html

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}
provider "tls" {
}

resource "azurerm_resource_group" "swp" {
  name     = "swp-dev-stage"
  location = "eastus"
}

# resource "azurerm_resource_group" "eksResourceGroup" {
#   name = "MC_swp-dev-stage_swp-aks_eastus"
#   location = "eastus"
# }

resource "azurerm_virtual_network" "swp" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.swp.location
  resource_group_name = azurerm_resource_group.swp.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "swp" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.swp.name
  resource_group_name  = azurerm_resource_group.swp.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_kubernetes_cluster" "swp" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.swp.location
  resource_group_name = azurerm_resource_group.swp.name
  dns_prefix          = var.prefix
  
  node_resource_group = "${var.prefix}-aks-nodes"
  default_node_pool {
    name           = "default"
    node_count     = var.vm_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.swp.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  # identity {
  #   type = "SystemAssigned"
  # }

  tags = {
    Environment = "Stage"
  }
}

resource "azurerm_public_ip" "swp" {
  name                = "swp-dev-stage-public-ip"
  resource_group_name = azurerm_kubernetes_cluster.swp.node_resource_group
  location            = azurerm_kubernetes_cluster.swp.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

