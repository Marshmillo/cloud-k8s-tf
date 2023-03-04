data "azuread_client_config" "current"{}

resource "azuread_application" "spn" {
    display_name = var.service_principal_name
    owner = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "main" {
    application_id = azuread_application.spn.application_id
    app_role_assignment_required = false
    owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "spp" {
    service_principal_id = azuread_service_principal.main.object_id
}