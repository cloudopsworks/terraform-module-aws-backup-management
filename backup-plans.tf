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
      rule_name = format("%s-%s-rule", each.key, rule.key)
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

data "aws_iam_policy_document" "backup_service_role" {
  count = var.vault.create ? 1 : 0
  statement {
    sid = "AWSBackupAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "backup_service_role" {
  count              = var.vault.create ? 1 : 0
  name               = format("%s-service-role", local.name)
  assume_role_policy = data.aws_iam_policy_document.backup_service_role[count.index].json
  tags = local.all_tags
}

resource "aws_iam_role_policy_attachment" "backup_service_role" {
  count      = var.vault.create ? 1 : 0
  role       = aws_iam_role.backup_service_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "this" {
  for_each = merge([
    for key, plan in var.backup_plans : {
      for rkey, res in plan.resources : "${key}-${rkey}" => {
        plan_key = key
        resource = res
      }
    }
  ]...)
  name         = format("%s-selection", each.key)
  plan_id      = aws_backup_plan.this[each.value.plan_key].id
  iam_role_arn = var.vault.create ? aws_iam_role.backup_service_role[0].arn : each.value.role_arn
  dynamic "selection_tag" {
    for_each = try(each.value.resource.tags, [])
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
  dynamic "condition" {
    for_each = try(each.value.resource.conditions, [])
    content {
      dynamic "string_equals" {
        for_each = length(try(condition.value.string_equals, {})) > 0 ? [1] : []
        content {
          key   = condition.value.string_equals.key
          value = condition.value.string_equals.value
        }
      }
      dynamic "string_not_equals" {
        for_each = length(try(condition.value.string_not_equals, {})) > 0 ? [1] : []
        content {
          key   = condition.value.string_not_equals.key
          value = condition.value.string_not_equals.value
        }
      }
      dynamic "string_like" {
        for_each = length(try(condition.value.string_like, {})) > 0 ? [1] : []
        content {
          key   = condition.value.string_like.key
          value = condition.value.string_like.value
        }
      }
      dynamic "string_not_like" {
        for_each = length(try(condition.value.string_not_like, {})) > 0 ? [1] : []
        content {
          key   = condition.value.string_not_like.key
          value = condition.value.string_not_like.value
        }
      }
    }
  }
  resources     = try(each.value.resource.include_arns, [])
  not_resources = try(each.value.resource.exclude_arns, [])
}