# Generado por scripts/bootstrap-backend.sh -- no editar a mano.
# Backend remoto del estado de Terraform para el ambiente 'dev'.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-micontrolplane-tfstate"
    storage_account_name = "stmcptfstatedev01"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}
