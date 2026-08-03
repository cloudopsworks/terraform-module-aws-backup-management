##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Legal holds are provisioned through the awscc (Cloud Control) provider: the classic AWS
# provider exposes no legal hold resource. While a hold is active its recovery points cannot
# be deleted and lifecycle expiration is suspended. Removing an entry cancels the hold.
locals {
  # awscc expects tags as a list of key/value objects, unlike the map(string) used elsewhere.
  legal_hold_tags = [for key, value in local.all_tags : {
    key   = key
    value = value
  }]
}

resource "awscc_backup_legal_hold" "this" {
  for_each = var.legal_holds

  title       = each.value.title
  description = each.value.description

  recovery_point_selection = {
    vault_names          = try(each.value.recovery_point_selection.vault_names, [])
    resource_identifiers = try(each.value.recovery_point_selection.resource_identifiers, [])
    date_range = try(each.value.recovery_point_selection.date_range, null) == null ? null : {
      from_date = each.value.recovery_point_selection.date_range.from_date
      to_date   = each.value.recovery_point_selection.date_range.to_date
    }
  }

  tags = local.legal_hold_tags
}
