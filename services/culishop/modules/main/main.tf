data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ── Shared infra data — single source of truth ──
module "info" {
  source = "../../../../modules/info"
}

# Read KMS outputs from shared infra state (optional)
data "terraform_remote_state" "kms" {
  count   = var.kms_state_path != null ? 1 : 0
  backend = "local"
  config = {
    path = var.kms_state_path
  }
}

locals {
  vpc_id                = module.info.vpc_id
  private_app_subnets   = module.info.private_app_subnet_ids
  public_subnets        = module.info.public_subnet_ids
  app_sg_id             = module.info.app_security_group_id
  alb_sg_id             = module.info.alb_security_group_id
  data_sg_id            = module.info.data_security_group_id
  database_subnet_group = module.info.database_subnet_group_name
  private_data_subnets  = module.info.private_data_subnet_ids
  account_id            = data.aws_caller_identity.current.account_id
  ecr_registry          = module.info.ecr_registry
}
