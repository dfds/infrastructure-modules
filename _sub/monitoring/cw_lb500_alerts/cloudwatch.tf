resource "aws_cloudwatch_metric_alarm" "alb_500_errors" {
  count = var.deploy ? length(var.alb_arn_suffixes) : 0

  alarm_name                = "alb_500_errors ${var.alb_arn_suffixes[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = var.check_metric #"HTTPCode_ELB_5XX_Count"
  namespace                 = var.check_namespace
  period                    = var.check_period
  statistic                 = "Sum"
  threshold                 = var.check_threshold
  alarm_description         = "Checking for 500 errors on ALB"
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alb_500_errors[0].arn]
  ok_actions    = [aws_sns_topic.alb_500_errors[0].arn]

  dimensions          = { "LoadBalancer" = var.alb_arn_suffixes[count.index] }
  datapoints_to_alarm = 2
}
