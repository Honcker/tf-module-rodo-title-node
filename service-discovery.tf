resource "aws_service_discovery_private_dns_namespace" "rodo-title-dns-namespace" {
  name        = "rodo-title.${local.node_slug}"
  description = "rodo title dns namespace for ${var.node_shortcode}"
  vpc         = aws_vpc.rodo-title.id

  tags = local.default__tags
}

resource "aws_service_discovery_service" "proxy" {
  name = "proxy"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rodo-title-dns-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = local.default__tags
}

# This may come up again in the future -- if this error is encountered:
#    Service contains registered instances; delete the instances before deleting the service
# The 'instance' will need to be deleted, like this:
#      aws servicediscovery list-instances --service-id srv-nfo7bwcfbnjo4f2x
#      ( will give you the instance "Id" ):
#      aws servicediscovery deregister-instance --service-id srv-nfo7bwcfbnjo4f2x --instance-id=1ffbd030318f4b0289646c9752e09a03
#      {
#         "OperationId": "kqvoeeakoq62hha3xticyjswqyzmeb3w-63skbhii"
#      }
#      aws servicediscovery delete-service --id srv-nfo7bwcfbnjo4f2x

resource "aws_service_discovery_service" "server" {
  name = "server"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rodo-title-dns-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = local.default__tags
}

resource "aws_service_discovery_service" "storage" {
  name = "storage"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rodo-title-dns-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = local.default__tags
}

resource "aws_service_discovery_service" "nft" {
  name = "nft"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rodo-title-dns-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = local.default__tags
}

resource "aws_service_discovery_service" "camunda" {
  name = "camunda"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rodo-title-dns-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = local.default__tags
}
