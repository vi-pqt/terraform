# VPC Module
# main.tf contains VPC, Internet Gateway, Nat Gateway
# subnets.tf contains Subnets
# security_groups.tf contains Security Groups
# routes.tf contains Routes

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
# VPC
#######################
resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-vpc"
    }
  )

}

#######################
# Internet Gateway
#######################
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-igw"
    }
  )
}

#######################
# Nat Gateway
#######################
resource "aws_eip" "nat_eip" {
  count  = var.is_single_nat_gw ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.is_single_nat_gw ? 1 : 0
  allocation_id = var.is_single_nat_gw ? aws_eip.nat_eip[0].id : 0
  subnet_id     = var.is_single_nat_gw ? aws_subnet.public_subnets[0].id : 0

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-natgw"
    }
  )
}
