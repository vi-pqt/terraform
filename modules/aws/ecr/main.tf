#######################
# Local
#######################
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "terraform"
  }
}

#######################
# ECR Repository
#######################
resource "aws_ecr_repository" "ecr_repo" {
  count = length(var.short_names)
  name  = "${var.project_name}-${var.short_names[count.index]}"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.short_names[count.index]}-ecr"
    }
  )
}

#######################
# ECR Lifecycle Policy
#######################
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  count      = length(var.short_names)
  repository = aws_ecr_repository.ecr_repo[count.index].name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after 1 day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": { "type": "expire" }
    },
    {
      "rulePriority": 2,
      "description": "Keep only last 10 images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": { "type": "expire" }
    }
  ]
}
EOF
}

