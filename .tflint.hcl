plugin "terraform" {
  enabled = true
  version = "0.14.1"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_standard_module_structure" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled = false
}

rule "terraform_documented_variables" {
  enabled = false
}

plugin "aws" {
    enabled = true
    version = "0.45.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
