# AWS Account & Region
output "aws_account_id" {
  description = "AWS account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.id
}

# Caller checker — verify BEFORE typing "yes" on apply
output "caller_account_id" {
  description = "AWS Account ID — verify this is correct"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_user_arn" {
  description = "IAM identity applying — verify correct role/user"
  value       = data.aws_caller_identity.current.arn
}

output "caller_region" {
  description = "AWS Region — verify correct region"
  value       = data.aws_region.current.id
}

# KMS
output "kms_key_id" {
  description = "KMS key ID"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.kms.key_arn
}

output "kms_alias_name" {
  description = "KMS key alias name"
  value       = module.kms.alias_name
}
