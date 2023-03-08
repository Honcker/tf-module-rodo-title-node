# Creating VPC,name, CIDR and Tags
resource "aws_vpc" "rodo-title" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-vpc"
  })

  lifecycle {
    # Use a check to ensure that the length of the environment variable
    # together with the length of the node_shortcode does not exceed
    # the maximum number of characters necessary to comply with
    # naming restrictions of some resources in AWS.
    # This is not done via variable validation because only a single variable
    #   is accessible in the validation block.
    # And there is no need to restrict the user any more than necessary.

    precondition {
      condition     = (length(var.environment) + length(var.node_shortcode)) <= 21
      error_message = "The combined length of var.environment and var.node_shortcode has exceeded the maximum length that can be allowed."
    }
  }
}

data "aws_availability_zones" "all" {}

resource "aws_subnet" "public-subnets" {
  count             = 4
  cidr_block        = cidrsubnet(aws_vpc.rodo-title.cidr_block, 8, count.index * 8 + 2)
  vpc_id            = aws_vpc.rodo-title.id
  availability_zone = data.aws_availability_zones.all.names[count.index]

  map_public_ip_on_launch = "true"
  tags = merge(local.default__tags,
    {
      Name = "Public-Subnets-${local.node_slug}"
      Tier = "Public-Subnets-${local.node_slug}"
  })
}

resource "aws_subnet" "private-subnets" {
  count             = 4
  cidr_block        = cidrsubnet(aws_vpc.rodo-title.cidr_block, 12, count.index * 4 + 8)
  vpc_id            = aws_vpc.rodo-title.id
  availability_zone = data.aws_availability_zones.all.names[count.index]

  map_public_ip_on_launch = "false"
  tags = merge(local.default__tags,
    {
      Name = "Private-Subnets-${local.node_slug}"
      Tier = "Private-Subnets-${local.node_slug}"
  })
}

resource "aws_internet_gateway" "rodo-gw" {
  vpc_id = aws_vpc.rodo-title.id
  tags   = local.default__tags
}


# Creating Route Tables for Internet gateway
resource "aws_route_table" "rodo-title-public" {
  vpc_id = aws_vpc.rodo-title.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rodo-gw.id
  }
  tags = local.default__tags
}

resource "aws_route_table_association" "rodo-title-public-routes" {
  count          = 2
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.rodo-title-public.id
}
