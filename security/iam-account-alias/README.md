# Organisation account module 
This module can be used to define an account alias for an already created account.

## How do you use this module?

To use this module refer to it with a terragrunt wrapper in a tfvars file. (see [module
sources](https://github.com/gruntwork-io/terragrunt)).

For example, the following will point to the repo module source at the master branch:

```hcl
terragrunt = {
  terraform {
  source = "git::git@github.com:dfds/infrastructure-modules.git//security/iam-account-alias"
  }
}
```

This specific module requires the following variables to be present in the tfvars file along with the module reference:
* aws_region
* aws_account_name

A complete example of the tfvars file could look like this:

```hcl
terragrunt = {
  terraform {
  source = "git::git@github.com:dfds/infrastructure-modules.git//security/iam-account-alias"
  }
}

aws_region = "eu-central-1"
aws_account_name = "databaseaccount"
```
