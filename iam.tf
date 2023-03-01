resource "aws_iam_policy" "rodo-title-policy" {
  name        = "${local.node_slug}-rodo-title-policy"
  path        = "/"
  description = "Rodo Title policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:*",
          "rds:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
        "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "GetContainerSecrets"
        Action   = "ssm:GetParameters"
        Effect   = "Allow"
        Resource = "${local.params_envprefix}/*"
      },
      {
        Action   = ["ses:SendEmail"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = local.default__tags
}

resource "aws_iam_role" "rodo-title-role" {
  name                = "${local.node_slug}-rodo-title-role"
  managed_policy_arns = [aws_iam_policy.rodo-title-policy.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.default__tags
}

resource "aws_iam_policy" "lambda_title_automation" {
  name        = "${local.node_slug}-ec2_rds_lambda_policy"
  path        = "/"
  description = "EC2/RDS Lambda Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:DescribeTags",
          "logs:*",
          "ec2:DescribeInstanceTypes",
          "ec2:StopInstances",
          "ec2:DescribeInstanceStatus",
          "rds:StartDBCluster",
          "rds:StopDBCluster",
          "rds:ListTagsForResource",
          "rds:DescribeDBInstances",
          "rds:StopDBInstance",
          "rds:DescribeDBClusters",
          "rds:StartDBInstance"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.default__tags
}

resource "aws_iam_role" "lambda_title_automation" {
  name                = "${local.node_slug}-ec2_rds_lambda_role"
  managed_policy_arns = [aws_iam_policy.lambda_title_automation.arn, "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = local.default__tags
}
