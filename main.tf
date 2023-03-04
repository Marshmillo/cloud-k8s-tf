provider "azurerm" {
    features {

    }
}

resource "azurerm_Resource_group" "rg1" {
    name = var.rgname
    location = var.location
}

module "ServicePrincipal" {
    source = "./modules/ServicePrincipal"
    service_principal_name = var.service_principal_name

    depends_on = [
        azurerm_Resource_group.rg1
    ]
}

resource "azurerm_role_assigment" "rolespn" {
    scope = ""
    role_definition_name = "Contributor"
    principal_id = module.ServicePrincipal.service_principal_object_id

    depends_on = [
        module.ServicePrincipal
    ]
}

module "keyvault" {
    source = "./modules/keyvault"
    keyvault_name = var.keyvault_name
    location = var.location
    resource_group_name = var.rgname
    service_principal_name = module.ServicePrincipal.service_principal_name
    service_principal_object_id = module.ServicePrincipal.service_principal_object_id
    service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id
}

resource "azurerm_key_vault_secret" "" {
    name = module.ServicePrincipal.client_id
    value = module.ServicePrincipal.client_secret
    key_vault_id = module.keyvault.keyvault_id
}

module "aks" {
    source = "./modules/aks"
    service_principal_name = var.service_principal_name
    client_id = module.ServicePrincipal.client_id
    client_secret = module.ServicePrincipal.client_secret
    location = var.location
    resource_group_name = var.rgname
}