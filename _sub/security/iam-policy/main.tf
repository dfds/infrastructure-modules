# ------------------------------------------------------------------------------
# DEFINE IAM POLICIES
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# GENERATE ROUTE 53 ZONE POLICY
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "create_route53_zone" {
    statement {
        sid       = "Route53CreateZone"
        actions   = ["CreateHostedZone"]
        resources = ["*"]
        effect    = "Allow"
    }
}


# ------------------------------------------------------------------------------
# GENERATE CREATE S3 BUCKET POLICY
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "create_s3_bucket" {
    statement {
        sid       = "S3CreateBucket"
        actions   = [
                "s3:PutBucketPolicy",
                "s3:CreateBucket",
                "s3:PutBucketVersioning"
            ]
        resources = ["*"]
        effect    = "Allow"
    }
}