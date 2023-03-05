
# CICD-Related variables

variable "environment" {
  description = "name of the environment"
  type        = string

  validation {
    condition     = length(regexall("[^a-zA-Z0-9-]", var.environment)) == 0
    error_message = "Length of environment + length of node-shortcode must not exceed 22 characters that include only `0-9`, `A-z`, and `-` ... These variables must comply with resource naming restrictions in AWS."
    # LB TG can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen
    # environment is used with node_shortcode to name resources including service-discovery definitions, 
    #      dns (restricted characters, particularly no "_"), LB target groups (restricted length), etc.
  }
}

# /CICD-Related variables

variable "node_shortcode" {
  description = "node prefix, used in names of AWS resources, see validation requirements below"
  type        = string

  validation {
    # condition     = length(var.node_shortcode) <= 7 && length(regexall("[^a-zA-Z0-9-]", var.node_shortcode)) == 0
    condition     = length(regexall("[^a-zA-Z0-9-]", var.node_shortcode)) == 0
    error_message = "Length of environment + length of node-shortcode must not exceed 22 characters that include only `0-9`, `A-z`, and `-` ... These variables must comply with resource naming restrictions in AWS."
    # node_shortcode is used with environment to name resources including service-discovery definitions, 
    #      dns (restricted characters, particularly no "_"), LB target groups (restricted length), etc.
  }
}

variable "region" {
  description = "name of aws region"
  type        = string
}

variable "node_type" {
  # While not currently used, is required to pass
  description = "Not currently used; Would use if different node types caused variations with deployments"
  type        = string
}

variable "node_name" {
  description = "node name, which should be consistent across systems"
  type        = string
}

variable "node_ui_cfg" {
  # see deploy_node_infra_root/main.tf
  description = "object containing UI config for this node"
  type        = any
}

variable "network_trust_password_secret_arn" {
  description = "the arn of a secretsmanager secret containing the network trust store password"
  type        = string
  nullable    = false
}

variable "corda_my_legal_name" {
  description = "the corda legal name for the corda node"
  type        = string
  nullable    = false
}

variable "corda_my_email_address" {
  description = "the email address to attach to the corda node"
  type        = string
  nullable    = false
}

variable "corda_rpc_user" {
  description = "the rpc user name to attach to the corda node"
  type        = string
  nullable    = false
}

variable "corda_rpc_user_password_secret_arn" {
  description = "the arn of a secretsmanager secret containing the corda rpc user password"
  type        = string
  nullable    = false
}
