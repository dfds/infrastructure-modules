# Cloudtrail S3 module 
This module can be used to configure S3 bucket for storing AWS Cloudtrail in an aws account. 

## How do you use this module?

To use this module refer to it with a terragrunt wrapper in a tfvars file. (see [module
sources](https://github.com/gruntwork-io/terragrunt)).

For example, the following will point to the repo module source at the master branch:

```hcl
terragrunt = {
  terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/cloudtrail-s3"
  }
}
```

This specific module requires the following variables to be present in the tfvars file along with the module reference:
* aws_region
* cloudtrail_trail_name
* s3_bucket_name
* s3_key_prefix
* enable_cloudtrail

A complete example of the tfvars file could look like this:

```hcl
terragrunt = {
  terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/cloudtrail-3"
  }
}

aws_region = "eu-central-1"
s3_bucket_name = "mybucket"
```
