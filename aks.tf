resource "azurerm_kubernetes_cluster" "main" {
  name                      = "aks-${local.resource_suffix}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.main.name
  dns_prefix                = local.context_name
  automatic_channel_upgrade = "node-image"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                         = "default"
    vm_size                      = "Standard_DS2_v2"
    enable_auto_scaling          = true
    min_count                    = 1
    max_count                    = 3
    max_pods                     = 30
    os_disk_size_gb              = 30
    os_disk_type                 = "Ephemeral"
    os_sku                       = "CBLMariner"
    only_critical_addons_enabled = true
    vnet_subnet_id               = azurerm_subnet.aks.id
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed            = true
      azure_rbac_enabled = true
    }
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.main.id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  count                 = var.node_pool_count
  name                  = "nodepool${count.index}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_F4s_v2"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3
  max_pods              = 30
  os_disk_size_gb       = 30
  os_disk_type          = "Ephemeral"
  os_sku                = "CBLMariner"
  vnet_subnet_id        = azurerm_subnet.node_pool[count.index].id

  upgrade_settings {
    max_surge = "100%"
  }
}

resource "azurerm_role_assignment" "aks_rbac_reader" {
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.aks.id
  principal_id         = azurerm_kubernetes_cluster.main.identity.0.principal_id
}

resource "azurerm_role_assignment" "agw" {
  for_each = {
    "Contributor"               = azurerm_application_gateway.main.id
    "Reader"                    = azurerm_resource_group.main.id
    "Managed Identity Operator" = azurerm_user_assigned_identity.agw.id
  }
  scope                = each.value
  role_definition_name = each.key
  principal_id         = azurerm_kubernetes_cluster.main.addon_profile[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
