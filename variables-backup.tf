##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "vault" {
  description = "(optional) Vault Configuration"
  type = object({
    create                = optional(bool, true)
    name                  = optional(string, "")  # (optional) Name of the backup vault, required if vault_name_prefix is not set
    name_prefix           = optional(string, "")  # (optional) Name of the backup vault prefix, required if vault_name is not set
    encryption_create_key = optional(bool, false) # (optional) If true, a new KMS key will be created for encryption. Default is false
    encryption_key        = optional(string, "")  # (optional) The ARN of the KMS key to use for encryption. If not set, the default AWS Backup key will be used
    encryption_alias      = optional(string, "")  # (optional) The alias of the KMS key to use for encryption. If not set, the default AWS Backup key will be used, or the vault_encryption_key if set
    force_destroy         = optional(bool, false) # (optional) If true, the backup vault will be destroyed even if it contains backups. Default is false
  })
  default = {
    create           = false
    name             = ""
    name_prefix      = ""
    air_gapped       = false
    encryption_key   = ""
    encryption_alias = ""
    force_destroy    = false
  }
}

variable "ram" {
  description = "(optional) If true, the backup vault will be shared with other AWS accounts."
  type = object({
    enabled  = optional(bool, false)
    accounts = optional(list(string), [])
  })
  default = {
    enabled  = false
    accounts = []
  }
}

variable "backup_plans" {
  description = "(optional) List of backup plans to create. If not set, no backup plans will be created"
  type        = any
  default     = {}
}

variable "legal_holds" {
  description = "(optional) List of legal holds to create. If not set, no legal holds will be created"
  type        = any
  default     = {}
}

variable "air_gapped" {
  description = "(optional) Air gapped vault configuration"
  type = object({
    enabled            = optional(bool, false)
    min_retention_days = optional(number, 0)
    max_retention_days = optional(number, 0)
  })
  default = {
    min_retention_days = 0
    max_retention_days = 0
  }
}

variable "region_settings" {
  description = "(optional) AWS Backup Region Settings configuration"
  type = object({
    enabled               = optional(bool, false)
    opt_ins               = optional(map(string), {})
    management_preference = optional(map(string), {})
  })
}