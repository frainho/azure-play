output "acr_user" {
  description = "User of Azure Container Registry Admin"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_password" {
  description = "Password of Azure Container Registry Admin"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "login_server" {
  description = "Login Server of Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}
