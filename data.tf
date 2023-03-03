data "aws_caller_identity" "current" {}

data "aws_route53_zone" "public" {
  provider = aws.dns
  name     = var.dns_public_domain
}

# data "aws_ssm_parameter" "node_entities_config" {
#   name = "/rodo-title/${var.environment}/node_entities_config"
# }

# system parameter containing json that stores the UIs maintained for this environment
# ie: {
#       "entities_to_maintain":["consumer_ny","dmv_ny"],
#       "node_entity_map":{"consumer_ny":{"path":"apps/consumer/out"},
#                          "dmv_ny":{"path":"apps/dmv/out"},
#                          "dealership_toyota":{"path":"apps/dealer/out"},
#                          "lender_hamilton":{"path":"apps/lender/out"}}
# }
# Note: There may be more elements in 'node_entity_map' than are set to be maintained.

# a key-value pair is added for s3bucket, which is then persisted in "/rodo-title/${var.environment}/node_entities_json"
# node_entities_json is used by CICD deployment.