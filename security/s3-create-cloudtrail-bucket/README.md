# Cloudtrail S3 module 
This module can be used to configure S3 bucket for storing AWS Cloudtrail in an aws account. 

## How do you use this module?

To use this module refer to it with a terragrunt wrapper in a tfvars file. (see [module
sources](https://github.com/gruntwork-io/terragrunt)).

For example, the following will point to the repo module source at the master branch:

```hcl
terragrunt = {
  terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/s3-create-cloudtrail-bucket"
  }
}
```

This specific module requires the following variables to be present in the tfvars file along with the module reference:
* aws_region
* cloudtrail_s3_bucket

The cloudtrail files that are put into the s3 bucket will have a default retention of 90 days.
This setting can be modified by providing this optional parameter 
* cloudtrail_logs_retention

A complete example of the tfvars file could look like this:

```hcl
terragrunt = {
  terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//security/s3-create-cloudtrail-bucket"
  }
}

aws_region = "eu-central-1"
cloudtrail_s3_bucket = "mybucket"
cloudtrail_logs_retention = 180 # Optional
```
