##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "vault_name" {
  description = "Name of the backup vault managed by this module. Null when vault.create is false."
  value       = local.vault_name
}

output "vault_arn" {
  description = "ARN of the backup vault managed by this module, standard or logically air-gapped. Null when vault.create is false."
  value       = local.vault_arn
}

output "vault_is_air_gapped" {
  description = "Whether the managed vault is a logically air-gapped vault."
  value       = var.vault.create && var.air_gapped.enabled
}

output "kms_key_arn" {
  description = "ARN of the KMS key protecting the vault, whether created by this module or supplied as input. Null when the vault is unencrypted or uses an AWS-owned key."
  value = local._enc.create ? aws_kms_key.create[0].arn : (
    local._enc.key != "" ? local._enc.key : (
      local._enc.alias != "" ? data.aws_kms_alias.key[0].target_key_arn : null
    )
  )
}

output "kms_key_id" {
  description = "Key ID of the KMS key created by this module. Null unless vault.encryption.create is true."
  value       = local._enc.create ? aws_kms_key.create[0].key_id : null
}

output "kms_alias_name" {
  description = "Name of the KMS alias created by this module. Null unless vault.encryption.create is true."
  value       = local._enc.create ? aws_kms_alias.create[0].name : null
}

output "backup_role_arn" {
  description = "ARN of the IAM backup service role created by this module. Null when vault.create is false, where per-plan role_arn values are used instead."
  value       = var.vault.create ? aws_iam_role.backup_service_role[0].arn : null
}

output "backup_role_name" {
  description = "Name of the IAM backup service role created by this module. Null when vault.create is false."
  value       = var.vault.create ? aws_iam_role.backup_service_role[0].name : null
}

output "backup_plan_ids" {
  description = "Map of backup plan key to backup plan ID."
  value       = { for key, plan in aws_backup_plan.this : key => plan.id }
}

output "backup_plan_arns" {
  description = "Map of backup plan key to backup plan ARN."
  value       = { for key, plan in aws_backup_plan.this : key => plan.arn }
}

output "backup_plan_versions" {
  description = "Map of backup plan key to the currently deployed plan version."
  value       = { for key, plan in aws_backup_plan.this : key => plan.version }
}

output "backup_selection_ids" {
  description = "Map of \"<plan_key>-<resource_key>\" to backup selection ID."
  value       = { for key, selection in aws_backup_selection.this : key => selection.id }
}

output "legal_hold_ids" {
  description = "Map of legal hold key to legal hold ID."
  value       = { for key, hold in awscc_backup_legal_hold.this : key => hold.legal_hold_id }
}

output "legal_hold_arns" {
  description = "Map of legal hold key to legal hold ARN."
  value       = { for key, hold in awscc_backup_legal_hold.this : key => hold.arn }
}

output "legal_hold_statuses" {
  description = "Map of legal hold key to the current status reported by AWS Backup."
  value       = { for key, hold in awscc_backup_legal_hold.this : key => hold.status }
}

output "ram_resource_share_arn" {
  description = "ARN of the AWS RAM resource share for the vault. Null when ram.enabled is false."
  value       = local.ram_enabled ? aws_ram_resource_share.this[0].arn : null
}

output "ram_shared_principals" {
  description = "Principals the vault is shared with through AWS RAM."
  value       = local.ram_enabled ? var.ram.accounts : []
}
