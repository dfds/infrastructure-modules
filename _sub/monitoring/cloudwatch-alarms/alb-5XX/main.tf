resource "aws_cloudwatch_metric_alarm" "alb_5XX" {
  count = var.deploy ? 1 : 0

  alarm_name                = "alb_5XX lb:${var.alb_arn_suffix}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = var.check_period
  statistic                 = "Sum"
  threshold                 = var.check_threshold
  alarm_description         = "Checking for 5XX on ALB"
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions          = { "LoadBalancer" = var.alb_arn_suffix }
  datapoints_to_alarm = 2
}
