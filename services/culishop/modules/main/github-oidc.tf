# ============================================================
# Session 15: GitHub Actions OIDC — CI/CD with zero access keys
# Toggle: var.enable_github_oidc
# Cost: $0 (IAM + OIDC are free)
#
# Uses terraform-aws-modules/iam/aws submodules:
#   - iam-oidc-provider: creates OIDC provider (auto thumbprint)
#   - iam-role: creates IAM role with GitHub OIDC trust policy
#
# After apply, copy github_actions_role_arn output and set as
# AWS_ROLE_ARN secret in your GitHub repo settings.
# ============================================================

# ── OIDC Identity Provider (one per AWS account) ──
module "github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "6.4.0"

  create = var.enable_github_oidc
  url    = "https://token.actions.githubusercontent.com"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── IAM Role with GitHub OIDC trust policy ──
module "github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.4.0"

  create = var.enable_github_oidc
  name   = "${var.project}-${var.environment}-github-actions"

  enable_github_oidc    = true
  oidc_wildcard_subjects = ["repo:${var.github_org}/${var.github_repo}:*"]

  policies = var.enable_github_oidc ? {
    ci = aws_iam_policy.github_actions_ci[0].arn
  } : {}

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── Least-privilege CI Policy ──
resource "aws_iam_policy" "github_actions_ci" {
  count = var.enable_github_oidc ? 1 : 0

  name   = "${var.project}-${var.environment}-github-actions-ci"
  policy = data.aws_iam_policy_document.github_actions_ci[0].json

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "github_actions_ci" {
  count = var.enable_github_oidc ? 1 : 0

  # ECR GetAuthorizationToken — required on * (AWS API limitation)
  statement {
    sid       = "ECRAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # ECR push — scoped to project repos
  statement {
    sid = "ECRPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.project}/*"
    ]
  }

  # ECS read-only — for deployment verification
  statement {
    sid = "ECSRead"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
    ]
    resources = ["*"]
  }
}
