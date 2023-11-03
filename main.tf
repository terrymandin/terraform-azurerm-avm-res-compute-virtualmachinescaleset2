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
}

resource "azurerm_management_lock" "this" {
  count      = var.lock.kind != "None" ? 1 : 0
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set.id
  lock_level = var.lock.kind
}