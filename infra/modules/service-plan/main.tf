# Modulo: service-plan
# Crea un Azure App Service Plan dedicado por dominio (ADR-0020).
# Un plan por dominio aísla el computo y permite DurabilityMode.Solo en Wolverine.
# Fuente de referencia: Bitakora.ControlAsistencia/infra/modules/service-plan/main.tf

variable "name" {
  description = "Nombre del App Service Plan (convencion: asp-<prefix_func>-<dominio>)"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del resource group"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
}

variable "os_type" {
  description = "Sistema operativo del plan: Linux o Windows"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU del plan: B1=Basic (minimo para .NET isolated), EP1=Elastic Premium"
  type        = string
  default     = "B1"
}

variable "worker_count" {
  description = "Numero de workers (instancias). 1 = DurabilityMode.Solo de Wolverine"
  type        = number
  default     = 1
}

variable "always_on" {
  description = "Mantener la app siempre activa (requiere B1 o superior; no disponible en Consumption)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comunes del proyecto"
  type        = map(string)
  default     = {}
}

resource "azurerm_service_plan" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  worker_count        = var.worker_count
  tags                = var.tags
}

output "id" {
  description = "ID del App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "Nombre del App Service Plan"
  value       = azurerm_service_plan.this.name
}
