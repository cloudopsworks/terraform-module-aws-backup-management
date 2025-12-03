##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "aws_backup_region_settings" "this" {
  count                               = var.region_settings.enabled ? 1 : 0
  resource_type_opt_in_preference     = var.region_settings.opt_ins
  resource_type_management_preference = var.region_settings.management_preference
}