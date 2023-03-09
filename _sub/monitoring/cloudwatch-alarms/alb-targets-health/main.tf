resource "aws_cloudwatch_metric_alarm" "alb_target_exists" {
  count = var.deploy ? 1 : 0

  alarm_name                = "alb_target_exists lb:${var.alb_arn_suffix} tg:${var.alb_arn_target_group_suffix}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = var.alb_target_exists_check_period
  statistic                 = "Minimum"
  threshold                 = var.alb_target_exists_check_threshold
  alarm_description         = "Checking that some healthy target exists on ALB"
  insufficient_data_actions = []

  treat_missing_data = "breaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    "TargetGroup"  = var.alb_arn_target_group_suffix
    "LoadBalancer" = var.alb_arn_suffix
  }
  datapoints_to_alarm = 2
}

resource "aws_cloudwatch_metric_alarm" "alb_target_healthy" {
  count = var.deploy ? 1 : 0

  alarm_name                = "alb_target_healthy lb:${var.alb_arn_suffix} tg:${var.alb_arn_target_group_suffix}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = var.alb_target_healthy_check_period
  statistic                 = "Average"
  threshold                 = var.alb_target_healthy_check_threshold
  alarm_description         = "Checking that no unhealthy targets on ALB"
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    "TargetGroup"  = var.alb_arn_target_group_suffix
    "LoadBalancer" = var.alb_arn_suffix
  }
  datapoints_to_alarm = 2
}
