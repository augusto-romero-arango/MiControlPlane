variable "subscription_id" {
  description = "ID de la suscripcion de Azure (suscripcion Augusto — nunca Azure Cosmos)"
  type        = string
  default     = "50fc1901-9723-4971-9d63-b3f1a015e8b8"
}

variable "environment" {
  description = "Nombre del ambiente"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Region principal de Azure para los recursos del proyecto"
  type        = string
  default     = "eastus2"
}

variable "postgresql_admin_password" {
  description = "Contrasena del administrador de PostgreSQL. Inyectar via TF_VAR_postgresql_admin_password; nunca en terraform.tfvars."
  type        = string
  sensitive   = true
}

locals {
  project = "micontrolplane"

  # Prefijo completo para la mayoria de recursos: rg, monitoring, service-bus
  prefix = "${local.project}-${var.environment}"

  # Prefijo corto para recursos con limite de caracteres (Function Apps, Storage Accounts).
  # func-mcp-<dominio>: el dominio mas largo es "tenant-provisioning" (18 chars)
  # -> "func-mcp-tenant-provisioning" = 28 chars < limite Azure de 32 chars.
  prefix_func = "mcp"

  tags = {
    proyecto   = local.project
    ambiente   = var.environment
    gestionado = "terraform"
  }
}
