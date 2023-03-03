resource "aws_key_pair" "rodo-title-deployer" {
  key_name   = "${local.node_slug}-rodo-title-deployer-key"
  public_key = var.ssh_public_key
  tags       = local.default__tags
}

data "aws_ami" "rodo-title-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.bastion_linux_ami_name]
  }
}


resource "aws_iam_instance_profile" "rodo-title-profile" {
  name = "${local.node_slug}-rodo-title-profile"
  role = aws_iam_role.rodo-title-role.name
  tags = merge(local.default__tags,
    {
      alarms = "rodo-title-${local.node_slug}"
  })
}

resource "aws_instance" "rodo-title-bastion" {
  count                  = 1
  ami                    = data.aws_ami.rodo-title-ami.id
  instance_type          = var.bastion_ec2_instance_type
  subnet_id              = aws_subnet.public-subnets[0].id
  key_name               = aws_key_pair.rodo-title-deployer.key_name
  vpc_security_group_ids = [aws_security_group.rodo-title-bastion-sg.id]
  monitoring             = true
  tags = merge(local.default__tags,
    {
      Name              = "${local.node_slug}-bastion-host"
      alarms            = "rodo-title-${local.node_slug}"
      instance_schedule = "yes"
  })
}

resource "aws_instance" "rodo-title-windows-bastion" {
  count                  = 1
  ami                    = var.bastion_windows_ami_id
  instance_type          = var.bastion_ec2_instance_type
  subnet_id              = aws_subnet.public-subnets[1].id
  key_name               = aws_key_pair.rodo-title-deployer.key_name
  vpc_security_group_ids = [aws_security_group.rodo-title-bastion-sg.id]
  monitoring             = true
  tags = merge(local.default__tags,
    {
      Name              = "${local.node_slug}-windows-bastion-host"
      alarms            = "rodo-title-${local.node_slug}"
      instance_schedule = "yes"
  })
}
