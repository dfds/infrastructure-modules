# --------------------------------------------------
# Init
# --------------------------------------------------

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region
  alias   = "core" # this provider does not seem to be used?
}

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region
  alias   = "shared"

  # Assume role in Shared account
  assume_role {
    role_arn = "arn:aws:iam::${var.shared_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region
  alias   = "workload"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${var.core_account_id}:root"] # Account ID from variable instead of data.aws_caller_identity - seems to get rate-throttled
}

module "iam_policies_shared" {
  source        = "../../_sub/security/iam-policies"
  replace_token = var.capability_root_id
}


# --------------------------------------------------
# Create account
# --------------------------------------------------

module "org_account" {
  source            = "../../_sub/security/org-account"
  name              = var.name
  org_role_name     = var.org_role_name
  email             = var.email
  parent_id         = var.parent_id
  master_account_id = var.master_account_id
  prime_role_name   = var.prime_role_name
  sleep_after       = 120
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

module "iam_idp" {
  source           = "../../_sub/security/iam-idp"
  provider_name    = "ADFS"
  adfs_fqdn        = var.adfs_fqdn
  assume_role_arns = [var.kiam_role_arn]

  providers = {
    aws = aws.workload
  }
}


# --------------------------------------------------
# IAM roles - Shared
# --------------------------------------------------

module "iam_role_shared" {
  source               = "../../_sub/security/iam-role"
  role_name            = var.capability_root_id
  role_path            = var.shared_role_path
  role_description     = "Namespaced access to resources in shared account, e.g. Parameter Store, CloudWatch Logs etc."
  max_session_duration = 28800 # 8 hours
  assume_role_policy   = data.aws_iam_policy_document.assume_role_adfs_shared.json
  role_policy_name     = "NamespacedAccessInSharedAccount"
  role_policy_document = module.iam_policies_shared.capability_access_shared

  providers = {
    aws = aws.shared
  }
}


# --------------------------------------------------
# IAM roles - Workload (capability context)
# --------------------------------------------------

module "iam_role_capability" {
  source               = "../../_sub/security/iam-role"
  role_name            = "Capability"
  role_description     = ""
  max_session_duration = 28800 # 8 hours
  assume_role_policy   = module.iam_idp.adfs_role_assume_policy
  role_policy_name     = "Admin"
  role_policy_document = module.iam_policies.admin

  providers = {
    aws = aws.workload
  }
}

module "iam_role_ecr_push" {
  source               = "../../_sub/security/iam-role"
  role_name            = "ecr-push"
  role_description     = ""
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_self.json
  role_policy_name     = "PushToECR"
  role_policy_document = module.iam_policies.push_to_ecr

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# IAM deployment user
# --------------------------------------------------

module "iam_user_deploy" {
  source               = "../../_sub/security/iam-user"
  user_name            = "Deploy"
  user_policy_name     = "Admin"
  user_policy_document = module.iam_policies.admin

  providers = {
    aws = aws.workload
  }
}

module "iam_user_deploy_store_credentials" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/managed/deploy/aws-creds"
  key_description = "AWS credentials for the IAM 'Deploy' user"

  key_value = <<EOF
AWS_ACCESS_KEY_ID=${module.iam_user_deploy.access_key}
AWS_SECRET_ACCESS_KEY=${module.iam_user_deploy.secret_key}
EOF


  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# aws_context_account_created event
# --------------------------------------------------

locals {
  # account_created_payload = <<EOF
  # {"contextId":"${var.context_id}","accountId":"${module.org_account.id}","roleArn":"${module.iam_role_capability.arn}","roleEmail":"${module.org_account.email}","capabilityRootId":"${var.capability_root_id}","capabilityName":"${var.capability_name}","contextName":"${var.context_name}","capabilityId":"${var.capability_id}"}EOF
  account_created_payload_map = {
    "contextId"        = var.context_id
    "accountId"        = module.org_account.id
    "roleArn"          = module.iam_role_capability.arn
    "roleEmail"        = module.org_account.email
    "capabilityRootId" = var.capability_root_id
    "capabilityName"   = var.capability_name
    "contextName"      = var.context_name
    "capabilityId"     = var.capability_id
  }

  account_created_payload_json = jsonencode(local.account_created_payload_map)
}

module "kafka_produce_account_created" {
  source          = "../../_sub/misc/kafka-message"
  publish         = var.publish_message
  event_name      = "aws_context_account_created"
  message_version = "1"
  correlation_id  = var.correlation_id
  sender          = "org-account-context created by terraform"
  payload         = local.account_created_payload_json
  key             = var.capability_id
  broker          = var.kafka_broker
  topic           = "build.selfservice.events.capabilities"
  username        = var.kafka_username
  password        = var.kafka_password
}
