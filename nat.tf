# Creating Nat Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnets[0].id
  depends_on    = [aws_internet_gateway.rodo-gw]

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-nat-gw"
  })
}

# Add routes for VPC
resource "aws_route_table" "rodo-title-private" {
  vpc_id = aws_vpc.rodo-title.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-rodo-title-rt"
  })
}

# Creating route associations for private Subnets
resource "aws_route_table_association" "rodo-title-private" {
  count          = 4
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.rodo-title-private.id
}
