terragrunt = {
  terraform {
    source = "git::https://github.com/dfds/infrastructure-modules.git//network/route53-sub-zone"
  }

    # Include all settings from the root terraform.tfvars file
    include = {
        path = "${find_in_parent_folders()}"
    }
    
}

dns_zone_name = "qa.dfds.cloud"