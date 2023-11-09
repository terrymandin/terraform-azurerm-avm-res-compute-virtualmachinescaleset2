resource "azurerm_orchestrated_virtual_machine_scale_set" "virtual_machine_scale_set" {
  name                        = var.name
  tags                        = var.tags 
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku_name                    = var.sku_name
  instances                   = var.instances
  
  platform_fault_domain_count = 1               # For zonal deployments, this must be set to 1
  zones                       = var.zones # ["1", "2", "3"] # Zones required to lookup zone in the startup script

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = var.os_profile.linux_configuration.admin_username
      admin_ssh_key {
        username   = var.os_profile.linux_configuration.admin_ssh_key.username
        public_key = var.os_profile.linux_configuration.admin_ssh_key.public_key
      }
    }
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  os_disk {
    storage_account_type = var.os_disk.storage_account_type
    caching              = var.os_disk.caching
  }

  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false
    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
    }
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  # Ignore changes to the instances property, so that the VMSS is not recreated when the number of instances is changed
  lifecycle {
    ignore_changes = [
      instances
    ]
  }

  identity {
    # VMSS Flex only supports User Assigned Managed Identities
    type = "UserAssigned"  
    identity_ids = var.managed_identities.user_assigned_resource_ids
  }

  dynamic "secret" {
    for_each = toset(var.secrets)

    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificate

        content {
          url   = certificate.value.url
          store = certificate.value.store
        }
      }
    }
  }
}

resource "azurerm_management_lock" "this" {
  count      = var.lock.kind != "None" ? 1 : 0
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set.id
  lock_level = var.lock.kind
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                       = var.diagnostic_settings
  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set.id
  storage_account_id             = each.value.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  partner_solution_id            = each.value.marketplace_partner_resource_id
  log_analytics_workspace_id     = each.value.workspace_resource_id
  log_analytics_destination_type = each.value.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_groups
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}


resource "azurerm_role_assignment" "this" {
  for_each                               = var.role_assignments
  scope                                  = azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set.id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  principal_id                           = each.value.principal_id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
}

