# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.21.0"
}

# --------------------------------------------------
# ECR repo and policy
# --------------------------------------------------

resource "aws_ecr_repository" "repo" {
  name  = "${var.name}"
}

resource "aws_ecr_repository_policy" "pol" {
  repository = "${aws_ecr_repository.repo.name}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "Allow pull from AWS IAM principals",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(var.pull_principals)}
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}