aws_workload_account_id = "266901158286" # 266901158286 = QA
workload_dns_zone_name = "qa.dfds.cloud"
terraform_state_s3_bucket = "dfds-qa-terraform-state"
terraform_state_region = "eu-central-1"
eks_public_s3_bucket = "dfds-qa-k8s-public"


# From EKS pipeline, for comparison
# aws_assume_role_arn = "arn:aws:iam::738063116313:role/Prime" # arn:aws:iam::738063116313:role/Prime = Prime role in Oxygen account