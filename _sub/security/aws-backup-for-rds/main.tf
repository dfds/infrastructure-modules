# Module to enable Backup through the accounts

# AWS Vault Creation
resource "aws_backup_vault" "vault" {
  name = var.vault_name
}

# Backup IAM Role
resource "aws_iam_role" "backup_role" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "backup.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = var.iam_role_name
  }
}

# KMS Key for Encryption
resource "aws_kms_key" "backup_key" {
  description             = "KMS key for backup encryption"
  enable_key_rotation     = true
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow backup service to use the key",
      "Effect": "Allow",
      "Principal": {
        "Service": "backup.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name = var.kms_key_alias
  }
}

# Backup Plan
resource "aws_backup_plan" "plan" {
  name        = var.backup_plan_name
  rule {
    rule_name         = "BackupRule"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 12 * * ? *)"
    lifecycle {
      delete_after       = 14
    }
  }
}
