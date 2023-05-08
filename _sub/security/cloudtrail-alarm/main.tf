resource "aws_cloudwatch_log_metric_filter" "filter" {
  count          = var.deploy ? 1 : 0
  name           = var.metric_filter_name
  pattern        = var.metric_filter_pattern
  log_group_name = var.logs_group_name

  metric_transformation {
    name      = var.metric_name
    namespace = var.metric_namespace
    value     = var.metric_value
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count                     = var.deploy ? 1 : 0
  alarm_name                = var.alarm_name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = var.metric_name
  namespace                 = var.metric_namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = var.alarm_description
  insufficient_data_actions = []
  alarm_actions             = [var.alarm_sns_topic_arn]

  depends_on = [aws_cloudwatch_log_metric_filter.filter]
}
