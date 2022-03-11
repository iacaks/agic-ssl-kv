resource "azurerm_container_registry" "main" {
  name                   = "cr${var.project}${var.environment}${var.location}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = var.location
  admin_enabled          = false
  sku                    = "Basic"
  anonymous_pull_enabled = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.main.id
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity.0.object_id
}
