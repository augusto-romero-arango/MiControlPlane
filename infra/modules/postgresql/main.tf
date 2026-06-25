# Modulo: postgresql
# Crea un Azure PostgreSQL Flexible Server (event store de Marten, ADR-0003).
# IMPORTANTE: la region debe ser "centralus"; eastus2 tiene restriccion LocationIsOfferRestricted
# para PostgreSQL Flexible Server (confirmado en Bitakora.ControlAsistencia).
# Fuente de referencia: Bitakora.ControlAsistencia/infra/modules/postgresql/main.tf

variable "name" {
  description = "Nombre del servidor PostgreSQL Flexible"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del resource group"
  type        = string
}

variable "location" {
  description = "Region de Azure (usar centralus; eastus2 tiene LocationIsOfferRestricted)"
  type        = string
}

variable "administrator_login" {
  description = "Usuario administrador de PostgreSQL"
  type        = string
}

variable "administrator_password" {
  description = "Contrasena del administrador de PostgreSQL"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Nombre de la base de datos a crear"
  type        = string
}

variable "zone" {
  description = "Zona de disponibilidad del servidor (null = Azure elige)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags comunes del proyecto"
  type        = map(string)
  default     = {}
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "17"
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  zone = var.zone

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "es_ES.utf8"
  charset   = "UTF8"
}

# Permite conexiones desde servicios de Azure (Function Apps sin VNet)
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "server_fqdn" {
  description = "FQDN del servidor PostgreSQL"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Nombre de la base de datos creada"
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "administrator_login" {
  description = "Usuario administrador del servidor"
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}
