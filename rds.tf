data "aws_subnets" "private-subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}


resource "aws_db_subnet_group" "rodo_db_sg" {
  name       = "${local.node_slug}-title-subnet-group"
  subnet_ids = [aws_subnet.private-subnets[0].id, aws_subnet.private-subnets[1].id, aws_subnet.private-subnets[3].id]

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-postgres-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "rodo-title-db-pg" {
  # name   = "${local.node_slug}-title-db-pg13"
  family = "postgres13"
  # family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default__tags,
    {
      Name = "${local.node_slug}-title-pg-db-param-group"
  })
}

data "aws_secretsmanager_secret" "rodo-title-db-password" {
  name = aws_secretsmanager_secret.rodo-title-db-password.name
}

data "aws_secretsmanager_secret_version" "rodo-title-db-password" {
  secret_id = data.aws_secretsmanager_secret.rodo-title-db-password.id
}

resource "aws_db_instance" "rodo-postgres-cordapp" {
  identifier                          = local.corda_db_aws_id
  availability_zone                   = data.aws_availability_zones.available_zones.names[0]
  allocated_storage                   = var.db_allocated_storage
  engine                              = var.db_engine
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  db_name                             = local.corda_db_name
  db_subnet_group_name                = aws_db_subnet_group.rodo_db_sg.name
  username                            = local.corda_db_master_user
  password                            = data.aws_secretsmanager_secret_version.rodo-title-db-password.secret_string
  parameter_group_name                = aws_db_parameter_group.rodo-title-db-pg.name
  skip_final_snapshot                 = true
  port                                = 5432
  publicly_accessible                 = false
  storage_encrypted                   = true # you should always do this
  storage_type                        = "gp2"
  vpc_security_group_ids              = [aws_security_group.rodo-title-db-sg.id]
  deletion_protection                 = false
  iam_database_authentication_enabled = true
  depends_on                          = [aws_db_subnet_group.rodo_db_sg]

  tags = local.default__tags
}

resource "aws_db_instance" "rodo-postgres-camunda" {
  identifier                          = local.camunda_db_aws_id
  availability_zone                   = data.aws_availability_zones.available_zones.names[1]
  allocated_storage                   = var.db_allocated_storage
  engine                              = var.db_engine
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  db_name                             = local.camunda_db_name
  db_subnet_group_name                = aws_db_subnet_group.rodo_db_sg.name
  username                            = local.camunda_db_master_user
  password                            = data.aws_secretsmanager_secret_version.rodo-title-db-password.secret_string
  parameter_group_name                = aws_db_parameter_group.rodo-title-db-pg.name
  skip_final_snapshot                 = true
  port                                = 5432
  publicly_accessible                 = var.db_public_accesible
  storage_encrypted                   = true # you should always do this
  storage_type                        = "gp2"
  vpc_security_group_ids              = [aws_security_group.rodo-title-db-sg.id]
  deletion_protection                 = false
  iam_database_authentication_enabled = true
  depends_on                          = [aws_db_subnet_group.rodo_db_sg]

  tags = local.default__tags
}
