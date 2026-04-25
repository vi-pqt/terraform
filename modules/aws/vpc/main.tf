locals {
  name = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = local.name
  cidr = var.vpc_cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_app_subnets
  database_subnets = var.private_data_subnets

  # NAT Gateway (~$32/mo when enabled)
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  # DNS
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Database subnet isolation — no internet access
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = false

  # Database subnet group (useful for RDS/ElastiCache)
  create_database_subnet_group = true

  # Public subnet settings
  map_public_ip_on_launch = true

  # Default security group hardening — restrict to no rules
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # Subnet naming
  public_subnet_names   = [for az in var.azs : "${var.project}-public-${substr(az, -2, 2)}"]
  private_subnet_names  = [for az in var.azs : "${var.project}-app-${substr(az, -2, 2)}"]
  database_subnet_names = [for az in var.azs : "${var.project}-data-${substr(az, -2, 2)}"]

  # Tier-specific tags
  public_subnet_tags = {
    Tier = "public"
  }
  private_subnet_tags = {
    Tier = "private-app"
  }
  database_subnet_tags = {
    Tier = "private-data"
  }

  # IGW and NAT naming
  igw_tags = {
    Name = "${local.name}-igw"
  }
  nat_gateway_tags = {
    Name = "${local.name}-nat"
  }
  nat_eip_tags = {
    Name = "${local.name}-nat-eip"
  }

  tags = local.common_tags
}

################################################################################
# Security Groups
################################################################################

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.name}-sg-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg-alb"
    Tier = "public"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from internet"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from internet"
}

resource "aws_security_group_rule" "alb_egress_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.alb.id
  description              = "Allow traffic to app tier"
}

# App Security Group
resource "aws_security_group" "app" {
  name        = "${local.name}-sg-app"
  description = "Security group for application tier (ECS Fargate)"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg-app"
    Tier = "private-app"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "app_ingress_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
  description              = "Allow traffic from ALB"
}

resource "aws_security_group_rule" "app_egress_data_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.data.id
  security_group_id        = aws_security_group.app.id
  description              = "Allow MySQL to data tier"
}

resource "aws_security_group_rule" "app_egress_data_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.data.id
  security_group_id        = aws_security_group.app.id
  description              = "Allow Redis to data tier"
}

resource "aws_security_group_rule" "app_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS to external APIs"
}

# Data Security Group
resource "aws_security_group" "data" {
  name        = "${local.name}-sg-data"
  description = "Security group for data tier (Aurora MySQL, ElastiCache Redis)"
  vpc_id      = module.vpc.vpc_id

  # Explicitly deny all outbound — override AWS default allow-all egress
  egress = []

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg-data"
    Tier = "private-data"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "data_ingress_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.data.id
  description              = "Allow MySQL from app tier"
}

resource "aws_security_group_rule" "data_ingress_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.data.id
  description              = "Allow Redis from app tier"
}
