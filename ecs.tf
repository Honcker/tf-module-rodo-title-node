
resource "aws_ecs_cluster" "rodo-title-cluster" {
  name = "rodo-title-${local.node_slug}"

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-proxy-task" {
  family                   = "proxy-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name  = "proxy"
      image = "${local.global_title_ecr_url}/rodo-title-proxy:${var.environment}_latest"

      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 8081
        }
      ]
      environment = [
        {
          name  = "GRPC_SERVICE_ADDRESS"
          value = "server.rodo-title.${local.node_slug}"
          # TODO: This is how the service discovery names should be set up
          #       Confirm that these environment vars should all be specific to node and not environment
        },
        {
          name  = "CAMUNDA_SERVICE_ADDRESS"
          value = "camunda.rodo-title.${local.node_slug}"
        },
        {
          name  = "STORAGE_SERVICE_ADDRESS"
          value = "storage.rodo-title.${local.node_slug}"
        },
        {
          name  = "LOG_LEVEL"
          value = "warn"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-proxy.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-proxy-svc" {
  name                 = "${local.node_slug}-proxy"
  cluster              = aws_ecs_cluster.rodo-title-cluster.id
  task_definition      = aws_ecs_task_definition.rodo-title-proxy-task.id
  force_new_deployment = true
  desired_count        = 1
  launch_type          = "FARGATE"

  network_configuration {
    subnets = [
      "${aws_subnet.public-subnets[0].id}",
      "${aws_subnet.public-subnets[1].id}",
    ]
    security_groups  = ["${aws_security_group.rodo-title-sg.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.proxy.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rodo-title-proxy-tg-group.arn
    container_name   = "proxy"
    container_port   = "8081"
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-server-task" {
  family                   = "server-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name   = "rodo-title-server"
      image  = "${local.global_title_ecr_url}/rodo-title-server:${var.environment}_latest"
      cpu    = 512
      memory = 1024
      portMappings = [
        {
          containerPort = 9090
        }
      ]
      environment = [
        {
          name  = "BASE_URL"
          value = "https://${local.node_slug}.dmv-ny.api.title.rodo.com"
        },
        {
          name  = "CAMUNDA_BASE_URL"
          value = "http://camunda.rodo-title.${local.node_slug}:8080/engine-rest"
        },
        {
          name  = "NFT_SERVICE"
          value = "nft.rodo-title.${local.node_slug}:8082"
        },
        {
          name  = "CORDA_NODE_ADDRESS"
          value = local.corda_address
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-server.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-server-svc" {
  name                 = "${local.node_slug}-server"
  cluster              = aws_ecs_cluster.rodo-title-cluster.id
  task_definition      = aws_ecs_task_definition.rodo-title-server-task.id
  force_new_deployment = true
  desired_count        = 1
  launch_type          = "FARGATE"


  network_configuration {
    subnets = [
      aws_subnet.private-subnets[0].id,
      aws_subnet.private-subnets[1].id,
      aws_subnet.private-subnets[2].id,
      aws_subnet.private-subnets[3].id
    ]
    security_groups  = ["${aws_security_group.rodo-title-sg.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.server.arn
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-storage-task" {
  family                   = "storage-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name   = "rodo-title-storage"
      image  = "${local.global_title_ecr_url}/rodo-title-storage:${var.environment}_latest"
      cpu    = 512
      memory = 1024
      portMappings = [
        {
          containerPort = 9090
        }
      ]
      environment = [
        {
          name  = "BASE_URL"
          value = "https://${local.node_slug}.dmv-ny.api.title.rodo.com"
        },
        {
          name  = "CAMUNDA_BASE_URL"
          value = "http://camunda.rodo-title.${local.node_slug}:8080/engine-rest"
        },
        {
          name  = "NFT_SERVICE"
          value = "nft.rodo-title.${local.node_slug}:8082"
        },
        {
          name  = "CORDA_NODE_ADDRESS"
          value = local.corda_address
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-storage.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-storage-svc" {
  name                 = "${local.node_slug}-storage"
  cluster              = aws_ecs_cluster.rodo-title-cluster.id
  task_definition      = aws_ecs_task_definition.rodo-title-storage-task.id
  force_new_deployment = true
  desired_count        = 1
  launch_type          = "FARGATE"


  network_configuration {
    subnets = [
      aws_subnet.private-subnets[0].id,
      aws_subnet.private-subnets[1].id,
      aws_subnet.private-subnets[2].id,
      aws_subnet.private-subnets[3].id
    ]
    security_groups  = ["${aws_security_group.rodo-title-sg.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.storage.arn
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-nft-task" {
  family                   = "nft-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name   = "rodo-title-nft"
      image  = "${local.global_title_ecr_url}/rodo-title-nft:${var.environment}_latest"
      cpu    = 512
      memory = 1024
      portMappings = [
        {
          containerPort = 8082
        }
      ]
      environment = [
        {
          name  = "CAMUNDA_BASE_URL"
          value = "http://camunda.rodo-title.${local.node_slug}:8080/engine-rest"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-nft.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }

      secrets = [
        {
          name      = "CONTRACT_ADDRESS"
          valueFrom = local.nft_secret_param_arns.wallet_address
        },
        {
          name      = "PRIVATE_KEY"
          valueFrom = local.nft_secret_param_arns.wallet_secret
        },
        {
          name      = "PINATA_API_KEY"
          valueFrom = local.nft_secret_param_arns.pinata_api_key
        },
        {
          name      = "PINATA_API_SECRET"
          valueFrom = local.nft_secret_param_arns.pinata_api_secret
        },
        {
          name      = "PINATA_JWT"
          valueFrom = local.nft_secret_param_arns.pinata_jwt
        }
      ]
    }
    ]
  )

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-nft-svc" {
  name                 = "${local.node_slug}-nft"
  cluster              = aws_ecs_cluster.rodo-title-cluster.id
  task_definition      = aws_ecs_task_definition.rodo-title-nft-task.id
  force_new_deployment = true
  desired_count        = 1
  launch_type          = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private-subnets[0].id,
      aws_subnet.private-subnets[1].id,
      aws_subnet.private-subnets[2].id,
      aws_subnet.private-subnets[3].id
    ]
    security_groups = ["${aws_security_group.rodo-title-sg.id}"]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nft.arn
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-camunda-task" {
  family                   = "camunda-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name    = "rodo-title-camunda"
      image   = "camunda/camunda-bpm-platform:run"
      command = ["./camunda.sh", "--webapps", "--rest", "--swaggerui"]
      cpu     = 512
      memory  = 1024
      portMappings = [
        {
          containerPort = 8080
        }
      ]
      environment = [
        {
          name  = "DB_DRIVER"
          value = "org.postgresql.Driver"
        },
        {
          name = "DB_URL"
          # value = "jdbc:postgresql://${aws_db_instance.rodo-postgres-camunda.endpoint}/camunda_${var.environment}"
          value = "jdbc:postgresql://${aws_db_instance.rodo-postgres-camunda.endpoint}/${local.camunda_db_name}"
        },
        {
          name  = "DB_USERNAME"
          value = local.camunda_app_uses_master
        },
        {
          name  = "DB_PASSWORD"
          value = data.aws_secretsmanager_secret_version.rodo-title-db-password.secret_string
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-camunda.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-camunda-svc" {
  name            = "${local.node_slug}-camunda"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-camunda-task.id
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets = [
      aws_subnet.private-subnets[0].id,
      aws_subnet.private-subnets[1].id,
      aws_subnet.private-subnets[2].id,
      aws_subnet.private-subnets[3].id
    ]
    security_groups  = ["${aws_security_group.rodo-title-sg.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.camunda.arn
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo-title-handler-task" {
  family                   = "handler-${local.node_slug}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name   = "rodo-title-handler"
      image  = "${local.global_title_ecr_url}/rodo-title-handler:${var.environment}_latest"
      cpu    = 1024
      memory = 2048
      environment = [
        {
          name  = "CAMUNDA_BASE_URL"
          value = "http://camunda.rodo-title.${local.node_slug}:8080/engine-rest"
        },
        {
          name  = "NFT_SERVICE"
          value = "nft.rodo-title.${local.node_slug}:8082"
        },
        {
          name  = "CORDA_NODE_ADDRESS"
          value = local.corda_address
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo-title-handler.name
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo-title-handler-svc" {
  name            = "${local.node_slug}-handler"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-handler-task.id
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets = [
      aws_subnet.private-subnets[0].id,
      aws_subnet.private-subnets[1].id,
      aws_subnet.private-subnets[2].id,
      aws_subnet.private-subnets[3].id
    ]
    security_groups = ["${aws_security_group.rodo-title-sg.id}"]
  }

  tags = local.default__tags
}

resource "aws_ecs_task_definition" "rodo_title_corda_node" {
  family                   = "${local.node_slug}_corda_node"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.rodo-title-role.arn
  task_role_arn            = aws_iam_role.rodo-title-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  volume {
    name = "truststore"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.corda.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.truststore.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "logs"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.corda.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.corda_logs.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name   = "rodo-title-corda-node"
      image  = "${local.global_title_ecr_url}/rodo-title-corda-node:${var.environment}"
      cpu    = 1024
      memory = 2048
      portMappings = [
        for p, v in local.corda_ports : { containerPort = v, hostPort = v }
      ]
      secrets = [
        {
          name      = "MY_LEGAL_NAME",
          valueFrom = aws_ssm_parameter.corda_my_legal_name.arn
        },
        {
          name      = "MY_PUBLIC_ADDRESS",
          valueFrom = aws_ssm_parameter.corda_my_public_address.arn
        },
        {
          name      = "NETWORKMAP_URL",
          valueFrom = aws_ssm_parameter.corda_networkmap_url.arn
        },
        {
          name      = "DOORMAN_URL",
          valueFrom = aws_ssm_parameter.corda_doorman_url.arn
        },
        {
          name      = "NETWORK_TRUST_PASSWORD",
          valueFrom = var.network_trust_password_secret_arn
        },
        {
          name      = "MY_EMAIL_ADDRESS",
          valueFrom = aws_ssm_parameter.corda_my_email_address.arn
        },
        {
          name      = "RPC_USER",
          valueFrom = aws_ssm_parameter.corda_rpc_user.arn
        },
        {
          name      = "RPC_PASSWORD",
          valueFrom = var.corda_rpc_user_password_secret_arn
        },
        {
          name      = "RPC_ADDRESS",
          valueFrom = aws_ssm_parameter.corda_rpc_address.arn
        },
        {
          name      = "RPC_ADMIN_ADDRESS",
          valueFrom = aws_ssm_parameter.corda_rpc_admin_address.arn
        },
        {
          name      = "corda_dataSourceProperties_dataSource_user",
          valueFrom = aws_ssm_parameter.corda_db_user.arn
        },
        {
          name      = "corda_dataSourceProperties_dataSource_password",
          valueFrom = aws_secretsmanager_secret.rodo-title-db-password.arn
        },
        {
          name      = "corda_dataSourceProperties_dataSource_url",
          valueFrom = aws_ssm_parameter.corda_db_connection_string.arn
        },
      ]
      environment = [
        {
          name  = "ACCEPT_LICENSE",
          value = "Y"
        },
        {
          name  = "SSHPORT",
          value = "2222"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "truststore"
          containerPath = "/opt/corda/certificates"
        },
        {
          sourceVolume  = "logs"
          containerPath = "/opt/corda/logs"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rodo_title_corda_node.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.default__tags
}

resource "aws_ecs_service" "rodo_title_corda_node" {
  name                               = "${local.node_slug}-corda-node"
  cluster                            = aws_ecs_cluster.rodo-title-cluster.id
  task_definition                    = aws_ecs_task_definition.rodo_title_corda_node.id
  desired_count                      = 1
  count                              = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  launch_type                        = "FARGATE"
  force_new_deployment               = true
  health_check_grace_period_seconds  = 120


  network_configuration {
    subnets         = aws_subnet.private-subnets[*].id
    security_groups = [aws_security_group.rodo-title-sg.id]
  }

  dynamic "load_balancer" {
    for_each = aws_lb_target_group.corda
    content {
      target_group_arn = load_balancer.value.arn
      container_name   = "rodo-title-corda-node"
      container_port   = load_balancer.value.port
    }
  }

  service_registries {
    registry_arn = aws_service_discovery_service.corda.arn
  }

  tags = local.default__tags
}
