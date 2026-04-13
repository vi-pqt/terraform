provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "kms" {
  source = "../../../../../modules/aws/kms"

  project_name = var.project_name
  environment  = var.environment
}
