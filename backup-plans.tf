##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 Lice

resource "aws_backup_plan" "this" {
  for_each = var.backup_plans
  name     = format("%s-%s-plan", each.key, local.system_name_short)
  dynamic "rule" {
    for_each = each.value.rules
    content {
      rule_name = format("%s-%s-rule", rule.key, local.system_name_short)
      target_vault_name = !var.vault.create ? rule.value.target_vault_name : (
        !var.air_gapped.enabled ? aws_backup_vault.this[0].name : (
          aws_backup_logically_air_gapped_vault.this[0].name
        )
      )
      schedule                     = try(rule.value.schedule, null)
      schedule_expression_timezone = try(rule.value.timezone, null)
      enable_continuous_backup     = try(rule.value.continuous_backup, false)
      start_window                 = try(rule.value.start_window, null)
      completion_window            = try(rule.value.completion_window, null)
      recovery_point_tags          = try(rule.value.recovery_point_tags, null)
      dynamic "lifecycle" {
        for_each = length(try(rule.value.lifecycle, {})) > 0 ? [1] : []
        content {
          cold_storage_after                        = try(rule.value.lifecycle.cold_storage_after, null)
          delete_after                              = try(rule.value.lifecycle.delete_after, null)
          opt_in_to_archive_for_supported_resources = try(rule.value.lifecycle.opt_in, null)
        }
      }
      dynamic "copy_action" {
        for_each = length(try(rule.value.copy_action, {})) > 0 ? [1] : []
        content {
          destination_vault_arn = try(rule.value.copy_action.destination_vault_arn, null)
          dynamic "lifecycle" {
            for_each = length(try(rule.value.copy_action.lifecycle, {})) > 0 ? [1] : []
            content {
              cold_storage_after                        = try(rule.value.copy_action.lifecycle.cold_storage_after, null)
              delete_after                              = try(rule.value.copy_action.lifecycle.delete_after, null)
              opt_in_to_archive_for_supported_resources = try(rule.value.copy_action.lifecycle.opt_in, null)
            }
          }
        }
      }
    }
  }
  dynamic "advanced_backup_setting" {
    for_each = length(try(each.value.advanced, {})) > 0 ? [1] : []
    content {
      backup_options = try(advanced_backup_setting.value.backup_options, null)
      resource_type  = try(advanced_backup_setting.value.resource_type, null)
    }
  }
  tags = local.all_tags
}