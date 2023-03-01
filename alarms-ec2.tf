data "aws_instances" "title-ec2-instances" {
  instance_tags = merge(local.default__tags,
    {
      alarms = "rodo-title-${local.node_slug}"
  })
}

resource "aws_cloudwatch_metric_alarm" "title-ec2-cpuutilization" {
  count               = length(data.aws_instances.title-ec2-instances.ids)
  alarm_name          = "title-EC2-CPU-${local.node_slug}-${data.aws_instances.title-ec2-instances.ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    InstanceId = data.aws_instances.title-ec2-instances.ids[count.index]
  }

  tags = local.default__tags
}
