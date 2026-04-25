data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "vpc" {
  source = "../../../../../modules/aws/vpc"

  project     = var.project
  environment = var.environment
  region      = var.region

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_app_subnets  = var.private_app_subnets
  private_data_subnets = var.private_data_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}
