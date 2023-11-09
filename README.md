<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/orchestrated_virtual_machine_scale_set) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The region where the resources will be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Virtual Machine Scale Set.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet where the Virtual Machine Scale Set will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_automatic_instance_repair"></a> [automatic\_instance\_repair](#input\_automatic\_instance\_repair)

Description: The automatic instance repair configuration for the Virtual Machine Scale Set.

Type:

```hcl
object({
    enabled      = optional(bool, false)
    grace_period = optional(number, 30)
  })
```

Default: `{}`

### <a name="input_capacity_reservation_group_id"></a> [capacity\_reservation\_group\_id](#input\_capacity\_reservation\_group\_id)

Description: The ID of the Capacity Reservation Group to associate with the Virtual Machine Scale Set.

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_instances"></a> [instances](#input\_instances)

Description: The number of instances in the Virtual Machine Scale Set.

Type: `number`

Default: `1`

### <a name="input_load_balancer_backend_address_pool_ids"></a> [load\_balancer\_backend\_address\_pool\_ids](#input\_load\_balancer\_backend\_address\_pool\_ids)

Description: A list of IDs of the backend address pools to associate with the load balancer.

Type: `list(string)`

Default: `[]`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply to the resources in this pattern. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: The managed identities to assign to the Virtual Machine Scale Set.

Type:

```hcl
object({
    system_assigned            = optional(bool, false) # System Assigned Managed Identity is not supported on VMSS
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk)

Description: The OS disk configuration for the Virtual Machine Scale Set.

Type:

```hcl
object({
    storage_account_type = optional(string, "Premium_LRS")
    caching              = optional(string, "ReadWrite")
  })
```

Default: `{}`

### <a name="input_os_profile"></a> [os\_profile](#input\_os\_profile)

Description: The OS profile configuration for the Virtual Machine Scale Set.

Type:

```hcl
object({
    linux_configuration = optional(object({
      disable_password_authentication = optional(bool, false)
      admin_username                  = optional(string, null)
      admin_password                  = optional(string, null) # When an admin_ssh_key is specified admin_password must be set to null
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
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the Virtual Machine Scale Set. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
  - `condition_version` - The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    }))
```

Default: `{}`

### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description:   list(object({  
    key\_vault\_id = "(Required) The ID of the Key Vault from which all Secrets should be sourced."  
    certificate  = set(object({  
      url   = "(Required) The Secret URL of a Key Vault Certificate. This can be sourced from the `secret_id` field within the `azurerm_key_vault_certificate` Resource."  
      store = "(Optional) The certificate store on the Virtual Machine where the certificate should be added. Required when use with Windows Virtual Machine."
    }))
  }))

  Example Inputs:

  ```terraform
  secrets = [
    {
      key_vault_id = azurerm_key_vault.example.id
      certificate = [
        {
          url = azurerm_key_vault_certificate.example.secret_id
          store = "My"
        }
      ]
    }
  ]
```

Type:

```hcl
list(object({
    key_vault_id = string
    certificate = set(object({
      url   = string
      store = optional(string)
    }))
  }))
```

Default: `[]`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The sku of the Virtual Machine Scale Set.

Type: `string`

Default: `"Standard_DS1_v2"`

### <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference)

Description: The source image reference for the Virtual Machine Scale Set.

Type:

```hcl
object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Map of tags to assign to the resources.

Type: `map(any)`

Default: `null`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: A list of Availability Zones which instances in the Virtual Machine Scale Set can be placed in.

Type: `list(string)`

Default:

```json
[
  "1",
  "2",
  "3"
]
```

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: n/a

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->