resource "aws_security_group" "rodo-title-bastion-sg" {
  name        = "${local.node_slug}-bastion-sg"
  description = "Bastion SG"
  vpc_id      = aws_vpc.rodo-title.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.129.245.23/32", "67.82.182.64/32", "24.115.163.142/32"]
  }

  # TODO: Move these CIDRs to local environment in vars.tf

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["73.129.245.23/32", "67.82.182.64/32", "72.208.71.165/32", "100.37.227.164/32"]
  }

  # TODO: Move these CIDRs to local environment in vars.tf

  ingress {
    description = "All TCP traffic to VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rodo-title.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-bastion-title-sg"
  })
}

resource "aws_security_group" "rodo-title-sg" {
  name        = "${local.node_slug}-title-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.rodo-title.id

  ingress {
    description = "Aall TCP traffic to VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rodo-title.cidr_block]
  }

  ingress {
    description     = "SSH Access from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.rodo-title-bastion-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-sg"
  })
}

resource "aws_security_group_rule" "rodo_title_to_self" {
  security_group_id        = aws_security_group.rodo-title-sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.rodo-title-sg.id
}

resource "aws_security_group_rule" "rodo_title_to_self" {
  for_each = local.corda_ports

  security_group_id = aws_security_group.rodo-title-sg.id
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "rodo-title-db-sg" {
  name        = "${local.node_slug}-title-db-sg"
  description = "Allow Rodo title sg inbound traffic"
  vpc_id      = aws_vpc.rodo-title.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rodo-title-sg.id]
  }

  ingress {
    description = ""
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rodo-title.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-db-sg"
  })
}

resource "aws_security_group" "rodo-title-alb-sg" {
  name        = "${local.node_slug}-rodo-title-alb-sg"
  description = "Port 80"
  vpc_id      = aws_vpc.rodo-title.id

  ingress {
    description      = "Allow Port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow Port 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all ip and ports outboun"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-alb-sg"
  })
}
