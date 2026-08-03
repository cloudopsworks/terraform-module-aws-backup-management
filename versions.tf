##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

terraform {
  required_version = ">= 1.3"
  # Complete with required providers for the module
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.35"
    }
    # Legal holds only. The classic AWS provider exposes no legal hold resource,
    # so awscc (Cloud Control) is used for aws_backup_legal_hold coverage.
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.95"
    }
  }
}
