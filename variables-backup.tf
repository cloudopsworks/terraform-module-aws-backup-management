##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

##
# YAML schema for vault configuration
#
# vault:
#   create: true               # (Optional) Whether to create a backup vault in this module. Default: true.
#   name: "primary"            # (Optional) Explicit vault name. Required if name_prefix is empty. Mutually exclusive with name_prefix.
#   name_prefix: "org-prod"    # (Optional) Prefix to build the vault name as "<prefix>-<system>-vault". Required if name is empty.
#   force_destroy: false       # (Optional) Allow vault deletion even if it contains recovery points. Default: false.
#
#   # Preferred encryption configuration
#   encryption:
#     create: false            # (Optional) Create a new KMS key and alias for this vault. Default: false.
#     key: ""                  # (Optional) Existing KMS Key ARN. Used when create=false.
#     alias: "alias/my-key"   # (Optional) Existing KMS Alias (format: alias/<name>). Used when key is empty and create=false.
#     deletion_window: 30     # (Optional) KMS key deletion window in days (7–30). Default: 30.
#     key_description: ""     # (Optional) Custom KMS key description. Default: auto-generated from vault name.
#     rotation_period: 90     # (Optional) KMS key rotation period in days (90–2560). Default: 90. Rotation is always enabled.
#
#   # DEPRECATED flat encryption fields — use vault.encryption.* above instead
#   encryption_create_key: false  # DEPRECATED: use vault.encryption.create
#   encryption_key: ""            # DEPRECATED: use vault.encryption.key
#   encryption_alias: ""          # DEPRECATED: use vault.encryption.alias
#
variable "vault" {
  description = "(optional) Vault Configuration"
  type = object({
    create      = optional(bool, true) # (Optional) Create the backup vault with this module. Default: true
    name        = optional(string, "") # (Optional) Vault name. Required if name_prefix is not set. Mutually exclusive with name_prefix
    name_prefix = optional(string, "") # (Optional) Vault name prefix. Required if name is not set. Mutually exclusive with name

    # Preferred encryption sub-object — takes precedence over the deprecated flat fields below.
    encryption = optional(object({
      create          = optional(bool, false) # (Optional) Create a new KMS key and alias for the vault. Default: false
      key             = optional(string, "")  # (Optional) Existing KMS Key ARN. Used when create=false
      alias           = optional(string, "")  # (Optional) Existing KMS Alias (format: alias/<name>). Used when key is empty and create=false
      deletion_window = optional(number, 30)  # (Optional) KMS key deletion window in days (7–30). Default: 30
      key_description = optional(string, "")  # (Optional) Custom description for the created KMS key. Default: auto-generated from vault name
      rotation_period = optional(number, 90)  # (Optional) KMS key rotation period in days (90–2560). Default: 90. Rotation is always enabled
    }), null)

    # DEPRECATED: use vault.encryption.create instead
    encryption_create_key = optional(bool, null) # DEPRECATED: use vault.encryption.create
    # DEPRECATED: use vault.encryption.key instead
    encryption_key = optional(string, null) # DEPRECATED: use vault.encryption.key
    # DEPRECATED: use vault.encryption.alias instead
    encryption_alias = optional(string, null) # DEPRECATED: use vault.encryption.alias

    force_destroy = optional(bool, false) # (Optional) Force destroy the vault even if it contains backups. Default: false
  })
  default = {
    create        = false
    name          = ""
    name_prefix   = ""
    force_destroy = false
  }
}

##
# YAML schema for AWS RAM (Resource Access Manager) sharing
#
# ram:
#   enabled: false              # (Optional) Enable sharing the vault using AWS RAM. Default: false.
#   accounts:                   # (Optional) List of AWS account IDs to share the vault with when enabled.
#     - "111122223333"
#     - "444455556666"
#
variable "ram" {
  description = "(optional) If true, the backup vault will be shared with other AWS accounts."
  type = object({
    enabled  = optional(bool, false)      # (Optional) Enable RAM sharing. Default: false
    accounts = optional(list(string), []) # (Optional) AWS Account IDs to share with when enabled. Default: []
  })
  default = {
    enabled  = false
    accounts = []
  }
}

##
# YAML schema for backup plans
# Reference: aws_backup_plan, aws_backup_selection, advanced_backup_setting
#
# backup_plans:
#   <plan_key>:
#     role_arn: "arn:aws:iam::<acct>:role/BackupServiceRole"   # (Optional) IAM role to use for selections when vault.create=false. Otherwise module-created role is used.
#     rules:                                   # (Required) Map of rules for this plan. Keys are rule identifiers.
#       <rule_key>:
#         schedule: "cron(0 12 * * ? *)"       # (Optional) CRON or rate expression. Example CRON: cron(0 12 * * ? *)
#         timezone: "UTC"                      # (Optional) IANA timezone for schedule evaluation. Example: UTC, America/New_York
#         continuous_backup: true               # (Optional) Enable continuous backup (point-in-time). Default: false
#         start_window: 60                      # (Optional) Minutes after scheduled time to start the job. Integer minutes.
#         completion_window: 180                # (Optional) Minutes after start window to complete the job. Integer minutes.
#         recovery_point_tags:                  # (Optional) Tags added to created recovery points.
#           "Owner": "backup"
#         lifecycle:                            # (Optional) Lifecycle settings for recovery points.
#           cold_storage_after: 30              # (Optional) Days after creation to move to cold storage.
#           delete_after: 365                   # (Optional) Days after creation to delete recovery points.
#           opt_in: true                        # (Optional) Archive for supported resources. Maps to opt_in_to_archive_for_supported_resources.
#         copy_action:                          # (Optional) Copy recovery points to another vault/region.
#           destination_vault_arn: "arn:aws:backup:us-west-2:<acct>:backup-vault:dest"
#           lifecycle:                          # (Optional) Lifecycle for copied recovery points.
#             cold_storage_after: 30            # (Optional) Days to move copy to cold.
#             delete_after: 365                 # (Optional) Days to delete copied recovery points.
#             opt_in: true                      # (Optional) Archive for supported resources on the copy.
#     advanced:                                 # (Optional) Advanced backup settings.
#       resource_type: "EC2"                    # (Optional) One of AWS Backup supported types: EC2, EBS, RDS, DDB, EFS, FSx, etc.
#       backup_options:                         # (Optional) Options vary by resource_type. Examples:
#         WindowsVSS: "enabled"                #   For EC2/Windows: WindowsVSS: enabled|disabled
#         DeleteResources: "false"             #   For EFS: DeleteResources: "true|false"
#     resources:                                # (Optional) Resource selection definitions for this plan.
#       <resource_key>:
#         tags:                                 # (Optional) Select by tags (list). Each item has type, key, value.
#           - type: "STRINGEQUALS"            #   (Required) One of: STRINGEQUALS
#             key: "backup"                   #   (Required) Tag key to match
#             value: "true"                   #   (Required) Tag value
#         conditions:                           # (Optional) Conditions list. Each entry must define one of the blocks below.
#           - string_equals:                    #   (Optional) Condition string_equals { key, value }
#               key: "aws:ResourceTag/Env"
#               value: "prod"
#           - string_like:                      #   (Optional) Condition string_like { key, value }
#               key: "aws:ResourceTag/App"
#               value: "*api*"
#         include_arns:                         # (Optional) Explicit ARNs to include.
#           - "arn:aws:ec2:us-east-1:111122223333:volume/vol-abc"
#         exclude_arns:                         # (Optional) Explicit ARNs to exclude.
#           - "arn:aws:ec2:us-east-1:111122223333:volume/vol-def"
#
variable "backup_plans" {
  description = "(optional) List of backup plans to create. If not set, no backup plans will be created"
  type        = any # (Optional) Free-form object map as documented above.
  default     = {}  # (Optional) No plans by default.
}

##
# YAML schema for legal holds
# Note: Legal hold support may require aws_backup_legal_hold resources. Define here for forward/extended usage.
#
# legal_holds:
#   <hold_key>:
#     description: "Case 1234"      # (Optional) Human description for the legal hold.
#     resource_arns:                 # (Required) List of ARNs under legal hold.
#       - "arn:aws:ec2:...:volume/vol-123"
#     tags:                          # (Optional) Tags to set on the legal hold.
#       "Case": "1234"
#
variable "legal_holds" {
  description = "(optional) List of legal holds to create. If not set, no legal holds will be created"
  type        = any # (Optional) Free-form object map as documented above.
  default     = {}  # (Optional) No legal holds by default.
}

##
# YAML schema for logically air-gapped vaults
#
# air_gapped:
#   enabled: false                   # (Optional) Create a logically air-gapped backup vault instead of a standard vault. Default: false.
#   min_retention_days: 0            # (Optional) Minimum retention allowed (days) for recovery points in the LAG vault.
#   max_retention_days: 0            # (Optional) Maximum retention allowed (days) for recovery points in the LAG vault.
#
variable "air_gapped" {
  description = "(optional) Air gapped vault configuration"
  type = object({
    enabled            = optional(bool, false) # (Optional) Enable logically air-gapped vault. Default: false
    min_retention_days = optional(number, 0)   # (Optional) Minimum retention in days. Default: 0
    max_retention_days = optional(number, 0)   # (Optional) Maximum retention in days. Default: 0
  })
  default = {
    min_retention_days = 0
    max_retention_days = 0
  }
}

##
# YAML schema for AWS Backup Region Settings
# Reference: aws_backup_region_settings
#
# region_settings:
#   enabled: false                 # (Optional) Enable applying AWS Backup region settings in this region. Default: false.
#   opt_ins:                       # (Optional) Map of resource type => ENABLED|DISABLED (e.g., LAMBDA, DYNAMODB, EFS, EBS, EC2, RDS, FSx, EKS, etc.)
#     "LAMBDA": "ENABLED"
#   management_preference:         # (Optional) Map of resource type => SYSTEM|USER for backup management preference.
#     "EBS": "SYSTEM"
#
variable "region_settings" {
  description = "(optional) AWS Backup Region Settings configuration"
  type = object({
    enabled               = optional(bool, false)     # (Optional) Enable region settings management. Default: false
    opt_ins               = optional(map(string), {}) # (Optional) Resource opt-in map. Values: ENABLED|DISABLED. Default: {}
    management_preference = optional(map(string), {}) # (Optional) Management preference map. Values: SYSTEM|USER. Default: {}
  })
}