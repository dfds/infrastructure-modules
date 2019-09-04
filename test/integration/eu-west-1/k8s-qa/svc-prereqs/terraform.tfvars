terragrunt {
  # Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
  # working directory, into a temporary folder, and execute your Terraform commands in that folder.
  terraform {
    source = "git::https://github.com/dfds/infrastructure-modules.git//compute/k8s-prereqs"
  }

  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../cluster"]
  }

}


# --------------------------------------------------
# AWS
# --------------------------------------------------

# aws_assume_role_arn = "arn:aws:iam::738063116313:role/Prime" # arn:aws:iam::738063116313:role/Prime = Prime role in Oxygen account


# --------------------------------------------------
# EKS
# --------------------------------------------------

eks_cluster_name = "qa"
