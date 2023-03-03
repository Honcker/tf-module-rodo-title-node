data "aws_s3_object" "title_ec2_autostop" {
  bucket = aws_s3_bucket.title-automation.bucket
  key    = "ec2_autostop.zip"
  depends_on = [
    aws_s3_object.title-automation
  ]
}

data "aws_s3_object" "title_ec2_autostart" {
  bucket = aws_s3_bucket.title-automation.bucket
  key    = "ec2_autostart.zip"
  depends_on = [
    aws_s3_object.title-automation
  ]
}

data "aws_s3_object" "title_rds_stop" {
  bucket = aws_s3_bucket.title-automation.bucket
  key    = "rds_stop.zip"
  depends_on = [
    aws_s3_object.title-automation
  ]
}

data "aws_s3_object" "title_rds_start" {
  bucket = aws_s3_bucket.title-automation.bucket
  key    = "rds_start.zip"
  depends_on = [
    aws_s3_object.title-automation
  ]
}

resource "aws_lambda_function" "title_ec2_autostop" {
  function_name = "${local.node_slug}-ec2_autostop"

  s3_bucket = aws_s3_bucket.title-automation.bucket
  s3_key    = data.aws_s3_object.title_ec2_autostop.key

  runtime = "python3.7"
  handler = "ec2_autostop.handler"

  role = aws_iam_role.lambda_title_automation.arn
}

resource "aws_lambda_function" "title_ec2_autostart" {
  function_name = "${local.node_slug}-ec2_autostart"

  s3_bucket = aws_s3_bucket.title-automation.bucket
  s3_key    = data.aws_s3_object.title_ec2_autostart.key

  runtime = "python3.7"
  handler = "ec2_autostart.handler"

  role = aws_iam_role.lambda_title_automation.arn
}

resource "aws_lambda_function" "title_rds_stop" {
  function_name = "${local.node_slug}-rds_stop"

  s3_bucket = aws_s3_bucket.title-automation.bucket
  s3_key    = data.aws_s3_object.title_rds_stop.key

  runtime = "python3.7"
  handler = "ec2_autostop.handler"

  role = aws_iam_role.lambda_title_automation.arn
}

resource "aws_lambda_function" "title_rds_start" {
  function_name = "${local.node_slug}-rds_start"

  s3_bucket = aws_s3_bucket.title-automation.bucket
  s3_key    = data.aws_s3_object.title_rds_start.key

  runtime = "python3.7"
  handler = "ec2_autostart.handler"

  role = aws_iam_role.lambda_title_automation.arn
}


resource "aws_lambda_permission" "title-ec2-stop-invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.title_ec2_autostop.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.title-ec2-stop-rule.arn
}

resource "aws_lambda_permission" "title-ec2-start-invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.title_ec2_autostart.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.title-ec2-start-rule.arn
}

resource "aws_lambda_permission" "title-rds-stop-invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.title_rds_stop.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.title-rds-stop-rule.arn
}

resource "aws_lambda_permission" "title-rds-start-invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.title_rds_start.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.title-rds-start-rule.arn
}