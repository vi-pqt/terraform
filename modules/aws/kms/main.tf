################################################################################
# KMS Key for sops encryption
################################################################################

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description         = var.description
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-sops"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_name}-${var.environment}-sops"
  target_key_id = aws_kms_key.this.key_id
}
