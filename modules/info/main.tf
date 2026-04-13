locals {
  account_id = "660880135138"
  region     = "ap-southeast-1"

  vpc_id         = "vpc-0da4cb9e0ea768c4a"
  vpc_cidr_block = "10.0.0.0/16"
  nat_gateway_id = []

  database_subnet_group_name = "culishop-dev-db-subnet-group"

  # Subnets
  public_subnets = [
    "subnet-0422a71f5a60c7862",
    "subnet-0e7d3b406b55afbb2",
    "subnet-0b839778ecbeed030",
  ]
  data_subnets = [
    "subnet-03a960508ebb2beec",
    "subnet-09a619ee56e3ecda4",
    "subnet-01f2f9d2a7106091c",
  ]
  private_subnets = [
    "subnet-0487e10148269fda5",
    "subnet-08b5bc6fe9f1c27a8",
    "subnet-09996ed0cef86bec2",
  ]

  # SG
  public_sg  = "sg-0e882c869d4f11054"
  alb_sg     = "sg-00876d6d655c0d4ae"
  private_sg = "sg-05a2677c8e0ea9bfb"
  data_sg    = "sg-0a3f69d460e63b89e"

  ecr_registry = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
