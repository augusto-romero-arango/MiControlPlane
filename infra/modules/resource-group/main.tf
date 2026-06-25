# Modulo: resource-group
# Crea un Azure Resource Group.
# Fuente de referencia: Bitakora.ControlAsistencia/infra/modules/resource-group/main.tf

variable "name" {
  description = "Nombre del resource group"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "Tags comunes del proyecto"
  type        = map(string)
  default     = {}
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

output "name" {
  description = "Nombre del resource group creado"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Region del resource group"
  value       = azurerm_resource_group.this.location
}

output "id" {
  description = "ID del resource group"
  value       = azurerm_resource_group.this.id
}
