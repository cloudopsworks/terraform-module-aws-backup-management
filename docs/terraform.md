## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.35 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | ~> 1.95 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.57.1 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 1.95.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.10 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_logically_air_gapped_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_logically_air_gapped_vault) | resource |
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_region_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_region_settings) | resource |
| [aws_backup_selection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_iam_role.backup_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_ram_principal_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [awscc_backup_legal_hold.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/backup_legal_hold) | resource |
| [aws_iam_policy_document.backup_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_air_gapped"></a> [air\_gapped](#input\_air\_gapped) | (optional) Air gapped vault configuration | <pre>object({<br/>    enabled            = optional(bool, false) # (Optional) Enable logically air-gapped vault. Default: false<br/>    min_retention_days = optional(number, 0)   # (Optional) Minimum retention in days. Default: 0<br/>    max_retention_days = optional(number, 0)   # (Optional) Maximum retention in days. Default: 0<br/>  })</pre> | <pre>{<br/>  "max_retention_days": 0,<br/>  "min_retention_days": 0<br/>}</pre> | no |
| <a name="input_backup_plans"></a> [backup\_plans](#input\_backup\_plans) | (optional) List of backup plans to create. If not set, no backup plans will be created | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_legal_holds"></a> [legal\_holds](#input\_legal\_holds) | (optional) Legal holds to create, keyed by name. Requires the awscc provider. If not set, no legal holds will be created | <pre>map(object({<br/>    title       = string # (Required) Short title of the legal hold<br/>    description = string # (Required) Description of the legal hold<br/>    recovery_point_selection = optional(object({<br/>      vault_names          = optional(list(string), []) # (Optional) Vault names whose recovery points are held. Default: []<br/>      resource_identifiers = optional(list(string), []) # (Optional) Resource ARNs whose recovery points are held. Default: []<br/>      date_range = optional(object({<br/>        from_date = string # (Required within date_range) Inclusive start, ISO 8601 date-time<br/>        to_date   = string # (Required within date_range) Inclusive end, ISO 8601 date-time<br/>      }), null)            # (Optional) Restrict the hold to a time window. Default: null (no restriction)<br/>    }), {})                # (Optional) Selection criteria. Default: {} (all recovery points)<br/>  }))</pre> | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_ram"></a> [ram](#input\_ram) | (optional) If true, the backup vault will be shared with other AWS accounts. | <pre>object({<br/>    enabled                   = optional(bool, false)      # (Optional) Enable RAM sharing. Default: false<br/>    accounts                  = optional(list(string), []) # (Optional) AWS Account IDs or organization ARNs to share with. Default: []<br/>    allow_external_principals = optional(bool, false)      # (Optional) Allow principals outside the AWS Organization. Default: false<br/>  })</pre> | <pre>{<br/>  "accounts": [],<br/>  "allow_external_principals": false,<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_region_settings"></a> [region\_settings](#input\_region\_settings) | (optional) AWS Backup Region Settings configuration | <pre>object({<br/>    enabled               = optional(bool, false)     # (Optional) Enable region settings management. Default: false<br/>    opt_ins               = optional(map(string), {}) # (Optional) Resource opt-in map. Values: ENABLED|DISABLED. Default: {}<br/>    management_preference = optional(map(string), {}) # (Optional) Management preference map. Values: SYSTEM|USER. Default: {}<br/>  })</pre> | n/a | yes |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |
| <a name="input_vault"></a> [vault](#input\_vault) | (optional) Vault Configuration | <pre>object({<br/>    create      = optional(bool, true) # (Optional) Create the backup vault with this module. Default: true<br/>    name        = optional(string, "") # (Optional) Vault name. Required if name_prefix is not set. Mutually exclusive with name_prefix<br/>    name_prefix = optional(string, "") # (Optional) Vault name prefix. Required if name is not set. Mutually exclusive with name<br/><br/>    # Preferred encryption sub-object — takes precedence over the deprecated flat fields below.<br/>    encryption = optional(object({<br/>      create          = optional(bool, false) # (Optional) Create a new KMS key and alias for the vault. Default: false<br/>      key             = optional(string, "")  # (Optional) Existing KMS Key ARN. Used when create=false<br/>      alias           = optional(string, "")  # (Optional) Existing KMS Alias (format: alias/<name>). Used when key is empty and create=false<br/>      deletion_window = optional(number, 30)  # (Optional) KMS key deletion window in days (7–30). Default: 30<br/>      key_description = optional(string, "")  # (Optional) Custom description for the created KMS key. Default: auto-generated from vault name<br/>      rotation_period = optional(number, 90)  # (Optional) KMS key rotation period in days (90–2560). Default: 90. Rotation is always enabled<br/>    }), null)<br/><br/>    # DEPRECATED: use vault.encryption.create instead<br/>    encryption_create_key = optional(bool, null) # DEPRECATED: use vault.encryption.create<br/>    # DEPRECATED: use vault.encryption.key instead<br/>    encryption_key = optional(string, "") # DEPRECATED: use vault.encryption.key<br/>    # DEPRECATED: use vault.encryption.alias instead<br/>    encryption_alias = optional(string, "") # DEPRECATED: use vault.encryption.alias<br/><br/>    force_destroy = optional(bool, false) # (Optional) Force destroy the vault even if it contains backups. Default: false<br/>  })</pre> | <pre>{<br/>  "create": false,<br/>  "force_destroy": false,<br/>  "name": "",<br/>  "name_prefix": ""<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arns"></a> [backup\_plan\_arns](#output\_backup\_plan\_arns) | Map of backup plan key to backup plan ARN. |
| <a name="output_backup_plan_ids"></a> [backup\_plan\_ids](#output\_backup\_plan\_ids) | Map of backup plan key to backup plan ID. |
| <a name="output_backup_plan_versions"></a> [backup\_plan\_versions](#output\_backup\_plan\_versions) | Map of backup plan key to the currently deployed plan version. |
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output\_backup\_role\_arn) | ARN of the IAM backup service role created by this module. Null when vault.create is false, where per-plan role\_arn values are used instead. |
| <a name="output_backup_role_name"></a> [backup\_role\_name](#output\_backup\_role\_name) | Name of the IAM backup service role created by this module. Null when vault.create is false. |
| <a name="output_backup_selection_ids"></a> [backup\_selection\_ids](#output\_backup\_selection\_ids) | Map of "<plan\_key>-<resource\_key>" to backup selection ID. |
| <a name="output_kms_alias_name"></a> [kms\_alias\_name](#output\_kms\_alias\_name) | Name of the KMS alias created by this module. Null unless vault.encryption.create is true. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key protecting the vault, whether created by this module or supplied as input. Null when the vault is unencrypted or uses an AWS-owned key. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | Key ID of the KMS key created by this module. Null unless vault.encryption.create is true. |
| <a name="output_legal_hold_arns"></a> [legal\_hold\_arns](#output\_legal\_hold\_arns) | Map of legal hold key to legal hold ARN. |
| <a name="output_legal_hold_ids"></a> [legal\_hold\_ids](#output\_legal\_hold\_ids) | Map of legal hold key to legal hold ID. |
| <a name="output_legal_hold_statuses"></a> [legal\_hold\_statuses](#output\_legal\_hold\_statuses) | Map of legal hold key to the current status reported by AWS Backup. |
| <a name="output_ram_resource_share_arn"></a> [ram\_resource\_share\_arn](#output\_ram\_resource\_share\_arn) | ARN of the AWS RAM resource share for the vault. Null when ram.enabled is false. |
| <a name="output_ram_shared_principals"></a> [ram\_shared\_principals](#output\_ram\_shared\_principals) | Principals the vault is shared with through AWS RAM. |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | ARN of the backup vault managed by this module, standard or logically air-gapped. Null when vault.create is false. |
| <a name="output_vault_is_air_gapped"></a> [vault\_is\_air\_gapped](#output\_vault\_is\_air\_gapped) | Whether the managed vault is a logically air-gapped vault. |
| <a name="output_vault_name"></a> [vault\_name](#output\_vault\_name) | Name of the backup vault managed by this module. Null when vault.create is false. |
