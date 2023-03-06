
resource "aws_ssm_parameter" "corda_my_legal_name" {
  name  = "${local.node_slug}_corda_my_legal_name"
  type  = "String"
  value = var.corda_my_legal_name
}

resource "aws_ssm_parameter" "corda_my_public_address" {
  name  = "${local.node_slug}_corda_my_public_address"
  type  = "String"
  value = "${aws_route53_record.corda_node.fqdn}:${local.corda_ports["p2p"]}"
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

resource "aws_ssm_parameter" "corda_rpc_address" {
  name  = "${local.node_slug}_corda_rpc_address"
  type  = "String"
  value = "${aws_route53_record.corda_node.fqdn}:${local.corda_ports["rpc"]}"
}

resource "aws_ssm_parameter" "corda_rpc_admin_address" {
  name  = "${local.node_slug}_corda_rpc_admin_address"
  type  = "String"
  value = "${aws_route53_record.corda_node.fqdn}:${local.corda_ports["rpcAdm"]}"
}

resource "aws_ssm_parameter" "corda_db_user" {
  name  = "${local.node_slug}_corda_db_user"
  type  = "String"
  value = aws_db_instance.rodo-postgres-cordapp.username
}

resource "aws_ssm_parameter" "corda_db_connection_string" {
  name  = "${local.node_slug}_corda_db_connection_string"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.rodo-postgres-cordapp.endpoint}:${aws_db_instance.rodo-postgres-cordapp.port}/${aws_db_instance.rodo-postgres-cordapp.db_name}"
}
