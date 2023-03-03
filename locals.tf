# Locals here are auto-constructed values.
# Locals in variables.tf are user-defined locals, like constants
#   that can change, but shouldn't change as often as variables.

locals {

  # Allow to choose a node-name that may or may not include the subenvironment name
  # but use subenvironment name in the naming of resources (node_slug)
  # this comes out of a discussion where Rodo requested naming consistency across systemsname
  # and a commitment was made to tag the resources [ with the name ]

  node_name = replace(var.node_name, "$swap-subenvironment-name", var.environment)
  node_slug = "${var.environment}-${var.node_shortcode}"

  default__tags = {
    node_name = local.node_name
    node_slug = local.node_slug
    node_type = var.node_type
  }

  is_ephemeral_env = substr(var.environment, 0, 4) == "dev-" ? true : false
  # shortcut that allows resources to more easily be destroyed
  # when designing such shortcuts, consider that it is sometimes better to fail
  # so that behavior during upgrades can be predictable.

  # db values are here because they are set up in the DB, and then referenced in the services
  # TODO: Consider using application level credentials, rather than master user credentials
  camunda_db_aws_id       = "${local.node_slug}-camunda-db"
  camunda_db_name         = "camunda"
  camunda_db_master_user  = "camunda"
  camunda_app_uses_master = local.camunda_db_master_user

  corda_db_aws_id       = "${local.node_slug}-corda-db"
  corda_db_name         = "cordapp"
  corda_db_master_user  = "cordapp"
  corda_app_uses_master = local.corda_db_master_user

  # secrets stored in parameters via github secrets + update-secrets pipeline
  nft_secret_params = {
    wallet_address    = "rodo-title/${local.node_slug}/NFT_CONTRACT_ADDRESS"
    wallet_secret     = "rodo-title/${local.node_slug}/NFT_WALLET_PRIVATE_KEY"
    pinata_api_key    = "rodo-title/${local.node_slug}/NFT_PINATA_API_KEY"
    pinata_api_secret = "rodo-title/${local.node_slug}/NFT_PINATA_API_SECRET"
    pinata_jwt        = "rodo-title/${local.node_slug}/NFT_PINATA_JWT"
  }

  params_envprefix = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter"

  nft_secret_param_arns = {
    for k, v in local.nft_secret_params : k => "${local.params_envprefix}/${v}"
  }

  # Entities JSON (SSM)

  entities_to_maintain        = toset([for entity in var.node_ui_cfg : entity.name])
  cloudfronted_entities_names = { for cfe in local.entities_to_maintain : cfe => replace(cfe, "_", "-") }

  node_entities_map = { for k, v in var.node_ui_cfg :
  v.name => merge({ path = v.path }, { s3bucket = "rodo-title-${local.node_slug}-${replace(v.name, "_", "-")}" }) }

  node_entities_json = {
    entities_to_maintain = tolist(local.entities_to_maintain)
    node_entity_map      = local.node_entities_map
  }

  # CF / ACM
  base_subdomain    = "${local.node_slug}.title.${data.aws_route53_zone.public.name}"
  ui_domain_names   = { for cfe in local.entities_to_maintain : cfe => "${local.cloudfronted_entities_names[cfe]}-ui.${local.base_subdomain}" }
  proxy_domain_name = "proxy.${local.base_subdomain}"

}
