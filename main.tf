##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  name = var.vault.name != "" ? var.vault.name : format("%s-%s-vault", var.vault.name_prefix, local.system_name_short)
}

data "aws_kms_alias" "key" {
  count = var.vault.encryption_alias != "" && !var.vault.encryption_create_key ? 1 : 0
  name  = var.vault.encryption_alias
}

resource "aws_kms_key" "create" {
  count                   = var.vault.encryption_create_key ? 1 : 0
  description             = format("KMS key for %s", local.name)
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.all_tags
}
resource "aws_kms_alias" "create" {
  count         = var.vault.encryption_create_key ? 1 : 0
  name          = format("alias/%s", local.name)
  target_key_id = aws_kms_key.create[count.index].key_id
}

resource "aws_backup_vault" "this" {
  count         = var.vault.create && !var.air_gapped.enabled ? 1 : 0
  name          = local.name
  force_destroy = var.vault.force_destroy
  kms_key_arn = var.vault.encryption_create_key ? aws_kms_key.create[0].arn : (
    var.vault.encryption_key != "" ? var.vault.encryption_key : (
      var.vault.encryption_alias != "" ? data.aws_kms_alias.key[0].target_key_arn : null
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