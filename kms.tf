
resource "aws_kms_key" "title-automation" {
  enable_key_rotation = true

  tags = local.default__tags
}

resource "aws_kms_alias" "title-automation" {
  name          = "alias/${local.node_slug}-automation-bucket"
  target_key_id = aws_kms_key.title-automation.key_id
}
