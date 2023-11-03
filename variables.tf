variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# Required variables
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The region where the resources will be deployed."
}

variable "tags" {
  type        = map(any)
  description = "Map of tags to assign to the resources."
  default     = null
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  description = "The lock level to apply to the resources in this pattern. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  default     = {}
  nullable    = false
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "name" {
  type        = string
  description = "The name of the Virtual Machine Scale Set."
  validation {
    condition = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The name must be between 1 and 64 characters long and cannot contain special characters \\/\"[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'"
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the Virtual Machine Scale Set will be deployed."
}

variable "sku_name" {
  type        = string
  description = "The sku of the Virtual Machine Scale Set."
  default     = "Standard_DS1_v2"
}

variable "instances" {
  type        = number
  description = "The number of instances in the Virtual Machine Scale Set."
  default     = 1
}
  
variable "capacity_reservation_group_id" {
  type        = string
  description = "The ID of the Capacity Reservation Group to associate with the Virtual Machine Scale Set."
  default     = null
}

variable "zones" {
  type        = list(string)
  description = "A list of Availability Zones which instances in the Virtual Machine Scale Set can be placed in."
  default     = ["1", "2", "3"]
}

variable "automatic_instance_repair" {
  type        = object({
    enabled      = optional(bool, false)
    grace_period = optional(number, 30)
  })
  description = "The automatic instance repair configuration for the Virtual Machine Scale Set."
  default     = {}
}

variable "os_profile" {
  type        = object({
    linux_configuration = optional(object({
      disable_password_authentication = optional(bool, false)
      admin_username                  = optional(string, null)
      admin_password                  = optional(string, null) # When an admin_ssh_key is specified admin_password must be set to null
      disable_password_authentication = optional(bool, true)
      user_data_base64                = optional(string, null)
      admin_ssh_key = optional(object({   # This is not optional in the underlying module
        username   = optional(string, null)
        public_key = optional(string, null)
      }), {}) # When an admin_password is specified disable_password_authentication must be set to false
    }), {})
    windows_configuration = optional(object({
      admin_username           = optional(string, null) # underlying module will default to name if null
      admin_password           = optional(string, null) # underlying module will default to name if null
      computer_name_prefix     = optional(string, null) # underlying module will default to name if null
      enable_automatic_updates = optional(bool, true)
      hotpatching_enabled      = optional(bool, false)             # Requires detailed validation
      patch_assessment_mode    = optional(string, "ImageDefault")  # How to set options "AutomaticByPlatform" or "ImageDefault"
      patch_mode               = optional(string, "AutomaticByOS") # How to set options Manual, AutomaticByOS and AutomaticByPlatform
      provision_vm_agent       = optional(bool, true)
    }), {})
  })
  description = "The OS profile configuration for the Virtual Machine Scale Set."
  default     = {}
}

variable "source_image_reference" {
  type        = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "The source image reference for the Virtual Machine Scale Set."
  default     = null
}

variable "os_disk" {
  type        = object({
    storage_account_type = optional(string, "Premium_LRS")
    caching              = optional(string, "ReadWrite")
  })
  description = "The OS disk configuration for the Virtual Machine Scale Set."
  default     = {}
}

variable "load_balancer_backend_address_pool_ids" {
  type        = list(string)
  description = "A list of IDs of the backend address pools to associate with the load balancer."
  default     = []
}

