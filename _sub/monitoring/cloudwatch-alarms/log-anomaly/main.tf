resource "aws_cloudwatch_metric_alarm" "log_anomaly" {
  count = var.deploy ? 1 : 0

  alarm_name          = "log-anomaly"
  comparison_operator = "LessThanLowerThreshold"
  evaluation_periods  = "5"
  datapoints_to_alarm = "2"

  metric_query {
    id = "m1"
    return_data = true

    metric {
      metric_name = "IncomingLogEvents"
      namespace   = "AWS/Logs"
      period      = var.check_period
      stat        = "Sum"

      dimensions = {
        LogGroupName = "/k8s/hellman/kube-system"
      }
    }
  }

  metric_query {
    id          = "ad1"
    label       = "IncomingLogEvents (expected)"
    expression  = "ANOMALY_DETECTION_BAND(m1, 1)"
    return_data = true
  }

  threshold_metric_id = "ad1"

  treat_missing_data = "missing"
  alarm_description  = "Checking sudden drop in log events"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}