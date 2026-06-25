# Infraestructura base compartida del ambiente dev — MiControlPlane
#
# Este archivo instancia los modulos BASE que todos los dominios referencian.
# Los modulos por-dominio (service-plan, storage, function-app) son instanciados
# por el domain-scaffolder al implementar cada bounded context.
#
# Referencias ADR: ADR-0001 (Service Bus), ADR-0003 (PostgreSQL/Marten),
#                  ADR-0006 (Function App por dominio), ADR-0020 (Plan por dominio)

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

# Log Analytics Workspace + Application Insights workspace-based.
# Nombre resultante del App Insights: "micontrolplane-dev-ai" (el modulo agrega -ai).
module "monitoring" {
  source              = "../../modules/monitoring"
  name                = local.prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

# Service Bus namespace SKU Standard (Basic no soporta topics; ADR-0001 exige 1 topic por evento).
# Los topics se crean bajo demanda al implementar cada dominio; no se declaran aqui.
module "service_bus" {
  source              = "../../modules/service-bus"
  name                = "sb-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  topics_config       = {}
  tags                = local.tags
}

# PostgreSQL Flexible Server — event store de Marten (ADR-0003).
# location = "centralus": eastus2 tiene restriccion LocationIsOfferRestricted para este servicio.
# Trade-off conocido: Function Apps en eastus2 cruzan region hacia Postgres en centralus.
module "postgresql" {
  source                 = "../../modules/postgresql"
  name                   = "psql-${local.prefix_func}-${var.environment}"
  resource_group_name    = module.resource_group.name
  location               = "centralus"
  administrator_login    = "pgadmin"
  administrator_password = var.postgresql_admin_password
  database_name          = "micontrolplane"
  tags                   = local.tags
}
