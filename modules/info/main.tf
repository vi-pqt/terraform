# ─────────────────────────────────────────────────────────────
# DATA REGISTRY — Single source of truth for shared infrastructure.
#
# Instead of opening AWS Console to copy-paste VPC IDs, services
# call this module. Update once → all services get the new values.
#
# HOW TO UPDATE:
#   1. Deploy shared infra (VPC, KMS, etc.)
#   2. Copy outputs into this file
#   3. Commit → all services automatically use new values
# ─────────────────────────────────────────────────────────────

locals {
  # ── Account & Region ──
  account_id = "226198813800"
  region     = "ap-southeast-1"

  # ── VPC (deployed via aws/culiops-sandbox/ap-southeast-1/vpc/lab/) ──
  vpc_id     = "vpc-0b0742d87435f5894"
  vpc_cidr   = "10.0.0.0/16"

  public_subnet_ids = [
    "subnet-0ae6b3db4c6db6c5b", # ap-southeast-1a
    "subnet-049866670dd38dceb", # ap-southeast-1b
    "subnet-0db318d1bba4f7956", # ap-southeast-1c
  ]

  private_app_subnet_ids = [
    "subnet-088df3095fad1b948", # ap-southeast-1a
    "subnet-00d160105d8686966", # ap-southeast-1b
    "subnet-03b22e698a2d5732d", # ap-southeast-1c
  ]

  private_data_subnet_ids = [
    "subnet-0d1b1a2e51f58121f", # ap-southeast-1a
    "subnet-05a7dada255ef04ec", # ap-southeast-1b
    "subnet-01e5ac22465123628", # ap-southeast-1c
  ]

  database_subnet_group_name = "culishop-lab"

  # ── Security Groups ──
  alb_security_group_id  = "sg-0623f0f8ecea6610c"
  app_security_group_id  = "sg-0ba92cfcf3ab80c12"
  data_security_group_id = "sg-057f0528a95e46c51"

  # ── ECR ──
  ecr_registry = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
