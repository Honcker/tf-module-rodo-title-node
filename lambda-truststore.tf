
data "archive_file" "truststore_archive" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/truststore"
  output_path = "${path.module}/lambda/truststore.zip"
}

data "aws_iam_policy_document" "truststore_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "truststore" {
  name               = "${local.node_slug}_truststoreLambda"
  assume_role_policy = data.aws_iam_policy_document.truststore_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "truststore" {
  role       = aws_iam_role.truststore.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "truststore" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess"
    ]
    resources = [
      aws_efs_file_system.corda.arn
    ]
  }
}

resource "aws_iam_policy" "truststore" {
  name   = "${local.node_slug}_truststoreLambdaPolicy"
  policy = data.aws_iam_policy_document.truststore.json
}

resource "aws_iam_role_policy_attachment" "truststore_policy" {
  policy_arn = aws_iam_policy.truststore.arn
  role       = aws_iam_role.truststore.name
}

resource "aws_lambda_function" "truststore" {
  function_name    = "${local.node_slug}_network_truststore"
  runtime          = "python3.9"
  handler          = "main.lambda_handler"
  role             = aws_iam_role.truststore.arn
  filename         = data.archive_file.truststore_archive.output_path
  source_code_hash = data.archive_file.truststore_archive.output_base64sha256
  timeout          = 360

  vpc_config {
    subnet_ids         = aws_subnet.private-subnets[*].id
    security_group_ids = [aws_security_group.rodo-title-sg.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.truststore.arn
    local_mount_path = "/mnt/opt/corda/certificates"
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_invocation" "truststore" {
  function_name = aws_lambda_function.truststore.function_name
  input = jsonencode({
    truststore_s3_uri          = var.truststore_s3_uri
  })
}
