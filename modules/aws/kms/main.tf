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

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-sops"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project}-${var.environment}-sops"
  target_key_id = aws_kms_key.this.key_id
}
