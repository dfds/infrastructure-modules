resource "aws_iam_policy" "integrity" {
  name = "IntegrityPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyDeletingVPCFlowLogs",
        Effect    = "Deny",
        Action    = ["ec2:DeleteFlowLogs"],
        Resource  = "*",
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/OrgRole",
              "arn:aws:iam::*:role/EKSAdmin",
            ],
          },
        },
      },
      {
        Sid       = "DenyDeletingCloudWatchLogs",
        Effect    = "Deny",
        Action    = [
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
        ],
        Resource  = "*",
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/EKSAdmin",
              "arn:aws:iam::*:role/OrgRole",
            ],
          },
        },
      },
      {
        Sid       = "DenyDisablingCloudTrail",
        Effect    = "Deny",
        Action    = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
        ],
        Resource  = "*",
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/OrgRole",
            ],
          },
        },
      },
      {
        Sid       = "DenyDisablingAccessAnalyzer",
        Effect    = "Deny",
        Action    = ["access-analyzer:DeleteAnalyzer"],
        Resource  = "*",
      },
      {
        Sid       = "DenyDisablingEditingAWSConfig",
        Effect    = "Deny",
        Action    = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder",
          "config:PutConfigRule",
        ],
        Resource  = "*",
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/OrgRole",
            ],
          },
        },
      },
    ],
  })
}
