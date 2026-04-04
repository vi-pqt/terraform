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
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.private_subnets[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-natgw"
    }
  )
}

#######################
# Subnets
#######################
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-public-${element(var.az, count.index)}"
    }
  )
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-private-${element(var.az, count.index)}"
    }
  )
}

resource "aws_subnet" "data_subnets" {
  count             = length(var.data_subnets)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.data_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-data-${element(var.az, count.index)}"
    }
  )
}

#######################
# Route Tables
#######################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-rtb-public"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-rtb-private"
    }
  )
}

resource "aws_route_table" "data_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-rtb-data"
    }
  )
}

resource "aws_route_table_association" "public_route_table_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# resource "aws_route_table_association" "public_route_table_igw_assoc" {
#   gateway_id     = aws_internet_gateway.igw_main.id
#   route_table_id = aws_route_table.public_route_table.id
# }

resource "aws_route_table_association" "private_route_table_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "data_route_table_assoc" {
  count          = length(var.data_subnets)
  subnet_id      = aws_subnet.data_subnets[count.index].id
  route_table_id = aws_route_table.data_route_table.id
}

resource "aws_route" "igw_public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw_main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "nat_private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

#######################
# Security Groups
#######################
# Public SG
resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}-${var.stage}-sg-public"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for public subnets which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-public"
      Tier = "Public"
    }
  )
}

# resource "aws_vpc_security_group_egress_rule" "public_sg_egress" {
#   description       = "Allow all outbound traffic for public subnets"
#   security_group_id = aws_security_group.public_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 0
#   to_port     = 0
#   ip_protocol = "-1"
# }

# resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress" {
#   description       = "Allow all inbound traffic for public subnets"
#   security_group_id = aws_security_group.public_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 443
#   to_port     = 443
#   ip_protocol = "tcp"
# }

# resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress_http" {
#   description       = "Allow all inbound traffic for public subnets"
#   security_group_id = aws_security_group.public_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 80
#   to_port     = 80
#   ip_protocol = "tcp"
# }

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.stage}-sg-alb"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for ALB which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-alb"
      Tier = "Public"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_https" {
  description       = "Allow all inbound traffic for ALB"
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_http" {
  description       = "Allow all inbound traffic for ALB"
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_egress" {
  description       = "Allow all outbound traffic for ALB"
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.private_sg.id
}

# Private SG
resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-${var.stage}-sg-private"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for private subnets which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-private"
      Tier = "Private"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress_alb" {
  description       = "Allow all inbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_db" {
  description       = "Allow all outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.data_sg.id
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_cache" {
  description       = "Allow all outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.data_sg.id
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_https" {
  description       = "Allow HTTPS outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4                    = "0.0.0.0/0"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id
}

# Data SG
resource "aws_security_group" "data_sg" {
  name        = "${var.project_name}-${var.stage}-sg-data"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for data subnets which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-data"
      Tier = "Data"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "data_sg_ingress_db" {
  description       = "Allow all inbound traffic for data subnets"
  security_group_id = aws_security_group.data_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.private_sg.id
}

resource "aws_vpc_security_group_egress_rule" "data_sg_ingress_cache" {
  description       = "Allow all outbound traffic for data subnets"
  security_group_id = aws_security_group.data_sg.id

  cidr_ipv4                    = var.vpc_cidr_block
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.private_sg.id
}

# Third Party SG
resource "aws_security_group" "third_party_sg" {
  name        = "${var.project_name}-${var.stage}-sg-third-party"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for third party subnets which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-third-party"
      Tier = "ThirdParty"
    }
  )
}
