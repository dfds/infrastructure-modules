# Cloudtrail module
This module can be used to configure A trail for AWS Cloudtrail in an aws account. The configured trail will send logs to an existing S3 bucket.

## How do you use this module?

To use this module refer to it with a terragrunt wrapper in a tfvars file. (see [module
sources](https://github.com/gruntwork-io/terragrunt)).

For example, the following will point to the repo module source at the master branch:

```hcl
terragrunt = {
  terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/cloudtrail"
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
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/cloudtrail"
  }
}

aws_region = "eu-central-1"
cloudtrail_trail_name = "mytrail"
s3_bucket_name = "mybucket"
s3_key_prefix = "myprefix"
enable_cloudtrail = true
```
