# Organisation account module 
This module can be used to provision AWS accounts in the organisation.

## How do you use this module?

To use this module in your Terraform templates, create a `module` resource and set its `source` field to the Git URL of
this repo. (see [module
sources](https://www.terraform.io/docs/modules/sources.html)).

For example, the following will point to the repo module source at the master branch:

```hcl
module "org-account" {
  source = "git::git@github.com:dfds/infrastructure-modules.git//security/org-account"
}
```
