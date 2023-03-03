resource "aws_cloudwatch_event_rule" "title-ec2-stop-rule" {
  name                = "${local.node_slug}-ec2-stop-rule"
  description         = "Rule to Trigger Function to stop EC2 instancees"
  schedule_expression = "cron(0 4 ? * FRI *)"

  tags = local.default__tags
}

resource "aws_cloudwatch_event_rule" "title-ec2-start-rule" {
  name                = "${local.node_slug}-ec2-start-rule"
  description         = "Rule to Trigger Function to start EC2 instancees"
  schedule_expression = "cron(0 9 ? * MON *)"

  tags = local.default__tags
}

resource "aws_cloudwatch_event_rule" "title-rds-stop-rule" {
  name                = "${local.node_slug}-rds-stop-rule"
  description         = "Rule to Trigger Function to stop RDS instancees"
  schedule_expression = "cron(0 4 ? * FRI *)"

  tags = local.default__tags
}

resource "aws_cloudwatch_event_rule" "title-rds-start-rule" {
  name                = "${local.node_slug}-rds-start-rule"
  description         = "Rule to Trigger Function to start RDS instancees"
  schedule_expression = "cron(30 3 ? * MON *)"
  tags                = local.default__tags
}

resource "aws_cloudwatch_event_target" "stop_title_ec2_instances" {
  arn  = aws_lambda_function.title_ec2_autostop.arn
  rule = aws_cloudwatch_event_rule.title-ec2-stop-rule.name
}

resource "aws_cloudwatch_event_target" "start_title_ec2_instances" {
  arn  = aws_lambda_function.title_ec2_autostart.arn
  rule = aws_cloudwatch_event_rule.title-ec2-start-rule.name
}


resource "aws_cloudwatch_event_target" "stop_title_rds_instances" {
  arn  = aws_lambda_function.title_rds_stop.arn
  rule = aws_cloudwatch_event_rule.title-rds-stop-rule.name
}

resource "aws_cloudwatch_event_target" "start_title_rds_instances" {
  arn  = aws_lambda_function.title_rds_start.arn
  rule = aws_cloudwatch_event_rule.title-rds-start-rule.name
}