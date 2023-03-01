
resource "aws_ecr_repository" "rodo-title-proxy-repo" {
  name         = "rodo-title-proxy-${local.node_slug}"
  force_delete = local.is_ephemeral_env
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default__tags
}

resource "aws_ecr_repository" "rodo-title-server-repo" {
  name         = "rodo-title-server-${local.node_slug}"
  force_delete = local.is_ephemeral_env

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default__tags
}

resource "aws_ecr_repository" "rodo-title-storage-repo" {
  name         = "rodo-title-storage-${local.node_slug}"
  force_delete = local.is_ephemeral_env

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default__tags
}

resource "aws_ecr_repository" "rodo-title-nft-repo" {
  name         = "rodo-title-nft-${local.node_slug}"
  force_delete = local.is_ephemeral_env

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default__tags
}

resource "aws_ecr_repository" "rodo-title-handler-repo" {
  name         = "rodo-title-handler-${local.node_slug}"
  force_delete = local.is_ephemeral_env

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default__tags
}

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
      name   = "proxy"
      image  = "${aws_ecr_repository.rodo-title-proxy-repo.repository_url}:latest"
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
  name            = "${local.node_slug}-proxy"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-proxy-task.id
  desired_count   = 1
  launch_type     = "FARGATE"

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
      image  = "${aws_ecr_repository.rodo-title-server-repo.repository_url}:latest"
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
  name            = "${local.node_slug}-server"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-server-task.id
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
      image  = "${aws_ecr_repository.rodo-title-storage-repo.repository_url}:latest"
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
  name            = "${local.node_slug}-storage"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-storage-task.id
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
      image  = "${aws_ecr_repository.rodo-title-nft-repo.repository_url}:latest"
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
  name            = "${local.node_slug}-nft"
  cluster         = aws_ecs_cluster.rodo-title-cluster.id
  task_definition = aws_ecs_task_definition.rodo-title-nft-task.id
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
      image  = "${aws_ecr_repository.rodo-title-handler-repo.repository_url}:latest"
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
