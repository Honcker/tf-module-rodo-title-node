resource "aws_cloudwatch_log_group" "rodo-title-proxy" {
  name = "/fargate/service/rodo-title-proxy-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      Name = "title-proxy-log-group-${local.node_slug}"
  })
}

resource "aws_cloudwatch_log_group" "rodo-title-server" {
  name = "/fargate/service/rodo-title-server-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      Name = "title-server-log-group-${local.node_slug}"
  })
}

resource "aws_cloudwatch_log_group" "rodo-title-storage" {
  name = "/fargate/service/rodo-title-storage-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      node_name = local.node_name
  })
}

resource "aws_cloudwatch_log_group" "rodo-title-nft" {
  name = "/fargate/service/rodo-title-nft-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      Name      = "title-nft-log-group-${local.node_slug}"
      node_name = local.node_name
  })
}

resource "aws_cloudwatch_log_group" "rodo-title-camunda" {
  name = "/fargate/service/rodo-title-camunda-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      Name = "title-camunda-log-group-${local.node_slug}"
  })
}

resource "aws_cloudwatch_log_group" "rodo-title-handler" {
  name = "/fargate/service/rodo-title-handler-${local.node_slug}"
  tags = merge(local.default__tags,
    {
      Name = "title-handler-log-group-${local.node_slug}"
  })
}
