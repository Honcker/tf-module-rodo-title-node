resource "random_password" "rodo-title-db-master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "rodo-title-db-password" {
  name                    = "title-${local.node_slug}-db"
  recovery_window_in_days = 0
  tags                    = local.default__tags

}

resource "aws_secretsmanager_secret_version" "rodo-title-db-password" {
  secret_id     = aws_secretsmanager_secret.rodo-title-db-password.id
  secret_string = random_password.rodo-title-db-master.result
}
