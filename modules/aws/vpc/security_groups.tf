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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-public"
      Tier = "Public"
    }
  )
}

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.stage}-sg-alb"
  vpc_id      = aws_vpc.vpc_main.id
  description = "Security group for ALB which allow HTTP and HTTPS traffic from the internet"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
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

  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-private"
      Tier = "Private"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress_alb" {
  description       = "Allow all inbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_db" {
  description       = "Allow all outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.data_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_cache" {
  description       = "Allow all outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.data_sg.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "private_sg_egress_https" {
  description       = "Allow HTTPS outbound traffic for private subnets"
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-data"
      Tier = "Data"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "data_sg_ingress_db" {
  description       = "Allow all inbound traffic for data subnets"
  security_group_id = aws_security_group.data_sg.id

  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "data_sg_ingress_cache" {
  description       = "Allow all outbound traffic for data subnets"
  security_group_id = aws_security_group.data_sg.id

  referenced_security_group_id = aws_security_group.private_sg.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-sg-third-party"
      Tier = "ThirdParty"
    }
  )
}
