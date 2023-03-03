# Uploads parameter for environment containing config for UIs for all nodes in environment

# resource "aws_ssm_parameter" "node_entity_json" {
#   name  = "/rodo-title/${var.environment}/node_entity_json"
#   type  = "String"
#   # insecure_value = jsonencode(local.node_entities_json)
#   value = jsonencode(local.node_entities_json)
#   overwrite = true

#   # not default tags because resource is at var.environment level
#   # and actually, this resources is being first created/managed
#   # by the first node, and then overwritten by the following nodes.
# }
