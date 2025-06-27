## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

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
| [aws_iam_policy_document.backup_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_air_gapped"></a> [air\_gapped](#input\_air\_gapped) | (optional) Air gapped vault configuration | <pre>object({<br/>    enabled            = optional(bool, false)<br/>    min_retention_days = optional(number, 0)<br/>    max_retention_days = optional(number, 0)<br/>  })</pre> | <pre>{<br/>  "max_retention_days": 0,<br/>  "min_retention_days": 0<br/>}</pre> | no |
| <a name="input_backup_plans"></a> [backup\_plans](#input\_backup\_plans) | (optional) List of backup plans to create. If not set, no backup plans will be created | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_legal_holds"></a> [legal\_holds](#input\_legal\_holds) | (optional) List of legal holds to create. If not set, no legal holds will be created | `any` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_ram"></a> [ram](#input\_ram) | (optional) If true, the backup vault will be shared with other AWS accounts. | <pre>object({<br/>    enabled  = optional(bool, false)<br/>    accounts = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "accounts": [],<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_region_settings"></a> [region\_settings](#input\_region\_settings) | (optional) AWS Backup Region Settings configuration | <pre>object({<br/>    enabled               = optional(bool, false)<br/>    opt_ins               = optional(map(string), {})<br/>    management_preference = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |
| <a name="input_vault"></a> [vault](#input\_vault) | (optional) Vault Configuration | <pre>object({<br/>    create                = optional(bool, true)<br/>    name                  = optional(string, "")  # (optional) Name of the backup vault, required if vault_name_prefix is not set<br/>    name_prefix           = optional(string, "")  # (optional) Name of the backup vault prefix, required if vault_name is not set<br/>    encryption_create_key = optional(bool, false) # (optional) If true, a new KMS key will be created for encryption. Default is false<br/>    encryption_key        = optional(string, "")  # (optional) The ARN of the KMS key to use for encryption. If not set, the default AWS Backup key will be used<br/>    encryption_alias      = optional(string, "")  # (optional) The alias of the KMS key to use for encryption. If not set, the default AWS Backup key will be used, or the vault_encryption_key if set<br/>    force_destroy         = optional(bool, false) # (optional) If true, the backup vault will be destroyed even if it contains backups. Default is false<br/>  })</pre> | <pre>{<br/>  "air_gapped": false,<br/>  "create": false,<br/>  "encryption_alias": "",<br/>  "encryption_key": "",<br/>  "force_destroy": false,<br/>  "name": "",<br/>  "name_prefix": ""<br/>}</pre> | no |

## Outputs

No outputs.
