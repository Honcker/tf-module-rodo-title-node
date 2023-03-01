data "aws_db_instance" "camunda_db_instance" {
  db_instance_identifier = aws_db_instance.rodo-postgres-camunda.identifier

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_burst_balance_low_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_burst_balance_low_${local.node_slug}_warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["BurstBalanceThreshold"]
  alarm_description   = "Average database storage burst balance over last 10 minutes too low, expect a significant performance drop soon"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_replica_lag_high_warning" {

  count = aws_db_instance.rodo-postgres-camunda.replicate_source_db == "" ? 0 : 1

  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_replica_lag_high_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["ReplicaLagWarningThreshold"]
  alarm_description   = "Average replica lag over last 10 minutes is high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_replica_lag_high_critical" {

  count = aws_db_instance.rodo-postgres-camunda.replicate_source_db == "" ? 0 : 1

  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_replica_lag_high_${local.node_slug}_critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["ReplicaLagCriticalThreshold"]
  alarm_description   = "Average replica lag over last 10 minutes is high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}



resource "aws_cloudwatch_metric_alarm" "camunda_cpu_utilization_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_cpu_utilization_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationWarningThreshold"]
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
resource "aws_cloudwatch_metric_alarm" "camunda_cpu_utilization_high_critical" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_cpu_utilization_high_${local.node_slug}_critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationCriticalThreshold"]
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
resource "aws_cloudwatch_metric_alarm" "camunda_database_connections_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_database_connections_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = var.instance_size_db_connections_map[data.aws_db_instance.db_instance.db_instance_class]
  alarm_description   = "The number of client network connections to the database instance is high."
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_disk_queue_depth_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_disk_queue_depth_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["DiskQueueDepthWarningThreshold"]
  alarm_description   = "Average database disk queue depth over last 10 minutes too high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_freeable_memory_low_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_freeable_memory_low_${local.node_slug}_warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["FreeableMemoryWarningThreshold"]
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
resource "aws_cloudwatch_metric_alarm" "camunda_freeable_memory_low_critical" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_freeable_memory_low_${local.node_slug}_critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["FreeableMemoryCriticalThreshold"]
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_free_storage_space_low_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_free_storage_space_low_warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["FreeStorageSpaceWarningThreshold"]
  alarm_description   = "The amount of available storage space is too low"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_free_storage_space_low_critical" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_free_storage_space_low_${local.node_slug}_critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["FreeStorageSpaceCriticalThreshold"]
  alarm_description   = "The amount of available storage space is too low"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}

resource "aws_cloudwatch_metric_alarm" "camunda_swap_usage_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_swap_usage_high_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["SwapUsageWarningThreshold"]
  alarm_description   = "Average database swap usage over last 10 minutes too high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
resource "aws_cloudwatch_metric_alarm" "camunda_read_latency_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_read_latency_high_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["ReadLatencyWarningThreshold"]
  alarm_description   = "The average amount of time taken per disk I/O operation is too high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
resource "aws_cloudwatch_metric_alarm" "camunda_write_latency_high_warning" {
  alarm_name          = "${aws_db_instance.rodo-postgres-camunda.id}_write_latency_high_${local.node_slug}_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = local.thresholds["WriteLatencyWarningThreshold"]
  alarm_description   = "The average amount of time taken per disk I/O operation is too high, performance may suffer"
  alarm_actions       = [aws_sns_topic.title_sns_topic.arn]
  ok_actions          = [aws_sns_topic.title_sns_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rodo-postgres-camunda.id
  }

  tags = {
    node_name = local.node_name
  }
}
