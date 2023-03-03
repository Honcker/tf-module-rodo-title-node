locals {
  alert_emails = var.sns_alert_emails
}

resource "aws_sns_topic" "title_sns_topic" {
  name = "${local.node_slug}-${var.sns_name}"
  tags = merge(local.default__tags,
    {
      alerts = "true"
  })
}

resource "aws_sns_topic_subscription" "title_alert_email_subscription" {
  count     = var.opt_alert_email_subscription_enabled ? length(local.alert_emails) : 0
  topic_arn = aws_sns_topic.title_sns_topic.arn
  protocol  = "email"
  endpoint  = local.alert_emails[count.index]
}
