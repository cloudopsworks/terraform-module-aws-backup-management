##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  name = var.vault.name != "" ? var.vault.name : format("%s-%s-vault", var.vault.name_prefix, local.system_name_short)

  # Effective encryption config.
  # vault.encryption sub-object takes precedence over the deprecated flat fields
  # (encryption_create_key, encryption_key, encryption_alias).
  # Key rotation is always enabled; rotation_period defaults to 90 days.
  _enc = var.vault.encryption != null ? var.vault.encryption : {
    create          = coalesce(var.vault.encryption_create_key, false)
    key             = coalesce(var.vault.encryption_key, "")
    alias           = coalesce(var.vault.encryption_alias, "")
    deletion_window = 30
    key_description = ""
    rotation_period = 90
  }
}

data "aws_kms_alias" "key" {
  count = local._enc.alias != "" && !local._enc.create ? 1 : 0
  name  = local._enc.alias
}

resource "aws_kms_key" "create" {
  count                   = local._enc.create ? 1 : 0
  description             = local._enc.key_description != "" ? local._enc.key_description : format("KMS key for %s", local.name)
  deletion_window_in_days = local._enc.deletion_window
  enable_key_rotation     = true
  rotation_period_in_days = local._enc.rotation_period
  tags                    = local.all_tags
}

resource "aws_kms_alias" "create" {
  count         = local._enc.create ? 1 : 0
  name          = format("alias/%s", local.name)
  target_key_id = aws_kms_key.create[count.index].key_id
}

resource "aws_backup_vault" "this" {
  count         = var.vault.create && !var.air_gapped.enabled ? 1 : 0
  name          = local.name
  force_destroy = var.vault.force_destroy
  kms_key_arn = local._enc.create ? aws_kms_key.create[0].arn : (
    local._enc.key != "" ? local._enc.key : (
      local._enc.alias != "" ? data.aws_kms_alias.key[0].target_key_arn : null
    )
  )
  tags = local.all_tags
}

resource "aws_backup_logically_air_gapped_vault" "this" {
  count              = var.vault.create && var.air_gapped.enabled ? 1 : 0
  name               = local.name
  min_retention_days = var.air_gapped.min_retention_days
  max_retention_days = var.air_gapped.max_retention_days
  tags               = local.all_tags
}