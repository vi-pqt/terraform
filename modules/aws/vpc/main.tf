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

  # ingress = [
  #   {
  #     from_port        = 443
  #     to_port          = 443
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #   },
  #   {
  #     from_port        = 80
  #     to_port          = 80
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #   }
  # ]

  # egress {
  #   from_port        = 0
  #   to_port          = 0
  #   protocol         = "-1"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-public"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "public_sg_egress" {
  description       = "Allow all outbound traffic for public subnets"
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress" {
  description       = "Allow all inbound traffic for public subnets"
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress_http" {
  description       = "Allow all inbound traffic for public subnets"
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
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
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress" {
  description                  = "Allow all outbound traffic for private subnets"
  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id

  cidr_ipv4   = var.vpc_cidr_block
  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress" {
  description       = "Allow all inbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4   = var.vpc_cidr_block
  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
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
    }
  )
}
