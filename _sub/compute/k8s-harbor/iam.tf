# resource "aws_iam_role_policy" "harbor_s3_bucket" {
#   name = "grant_harbor_s3_bucket_permissions"
#   role = "${var.worker_role_id}"

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:ListBucket",
#         "s3:GetBucketLocation",
#         "s3:ListBucketMultipartUploads"
#       ],
#       "Resource": "arn:aws:s3:::${var.bucket_name}"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:PutObject",
#         "s3:GetObject",
#         "s3:DeleteObject",
#         "s3:ListMultipartUploadParts",
#         "s3:AbortMultipartUpload"
#       ],
#       "Resource": "arn:aws:s3:::${var.bucket_name}/*"
#     }
#   ]
# }
# POLICY
# }
