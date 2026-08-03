##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Cross-account sharing of the backup vault through AWS RAM.
# Only applicable when this module owns the vault; there is nothing to share otherwise.
locals {
  ram_enabled = var.ram.enabled && var.vault.create
}

resource "aws_ram_resource_share" "this" {
  count                     = local.ram_enabled ? 1 : 0
  name                      = format("%s-share", local.name)
  allow_external_principals = var.ram.allow_external_principals
  tags                      = local.all_tags

  lifecycle {
    precondition {
      condition     = !var.ram.enabled || var.vault.create
      error_message = "ram.enabled requires vault.create to be true, because the module can only share a vault it manages."
    }
  }
}

resource "aws_ram_resource_association" "this" {
  count              = local.ram_enabled ? 1 : 0
  resource_arn       = local.vault_arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  for_each           = local.ram_enabled ? toset(var.ram.accounts) : toset([])
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
