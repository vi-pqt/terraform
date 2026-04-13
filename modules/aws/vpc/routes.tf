#######################
# Route Tables
#######################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rtb-public"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rtb-private"
    }
  )
}

resource "aws_route_table" "data_route_table" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rtb-data"
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
  count                  = var.is_single_nat_gw ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = var.is_single_nat_gw ? aws_nat_gateway.nat_gw[0].id : 0
  destination_cidr_block = "0.0.0.0/0"
}
