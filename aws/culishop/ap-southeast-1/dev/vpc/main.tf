data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#######################
# VPC
#######################
module "vpc" {
  source = "../../../../../modules/aws/vpc"

  project_name = var.project_name
  stage        = var.stage

  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  data_subnets       = var.data_subnets
  availability_zones = var.availability_zones

  common_tags = var.common_tags

  is_single_nat_gw = false # change to "true" if you want to use single NAT Gateway
}
