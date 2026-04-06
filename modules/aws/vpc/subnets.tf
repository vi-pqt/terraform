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
