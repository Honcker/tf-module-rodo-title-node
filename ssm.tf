
resource "aws_ssm_parameter" "corda_my_legal_name" {
  name  = "${local.node_slug}_corda_my_legal_name"
  type  = "String"
  value = var.corda_my_legal_name
}

resource "aws_ssm_parameter" "corda_my_public_address" {
  name  = "${local.node_slug}_corda_my_public_address"
  type  = "String"
  value = aws_route53_record.corda_node.fqdn
}

resource "aws_ssm_parameter" "corda_networkmap_url" {
  name  = "${local.node_slug}_corda_networkmap_url"
  type  = "String"
  value = var.corda_networkmap_url
}

resource "aws_ssm_parameter" "corda_doorman_url" {
  name  = "${local.node_slug}_corda_doorman_url"
  type  = "String"
  value = var.corda_doorman_url
}

resource "aws_ssm_parameter" "corda_my_email_address" {
  name  = "${local.node_slug}_corda_my_email_address"
  type  = "String"
  value = var.corda_my_email_address
}

resource "aws_ssm_parameter" "corda_rpc_user" {
  name  = "${local.node_slug}_corda_rpc_user"
  type  = "String"
  value = var.corda_rpc_user
}
