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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-public-${substr(var.availability_zones[count.index], -2, 2)}"
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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-private-${substr(var.availability_zones[count.index], -2, 2)}"
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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-data-${substr(var.availability_zones[count.index], -2, 2)}"
    }
  )
}
