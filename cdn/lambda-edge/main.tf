# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.12.2"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.21.0"  # from 2.11 Minimum required 2.14

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "aws_lambda_edge_function" {
  source = "../../_sub/compute/lambda-edge"
  deploy = "${var.deploy_lambda_edge_func}"
  lambda_function_name = "${var.lambda_edge_prefix}-cf-redirect-rules"
  lambda_role_name = "${var.lambda_edge_prefix}-cf-redirect-rules"
  lambda_function_handler = "${var.lambda_function_handler}"   
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${module.s3_object_upload_lambda_edge.s3_object_key}"
  publish = true  
}

# The zip file to be used for creating the lambda@edge function
module "s3_object_upload_lambda_edge" {
  source = "../../_sub/misc/s3-bucket-object"
  deploy = "${var.deploy_lambda_edge_func}"
  s3_bucket = "${var.s3_bucket}"
  key = "${var.lambda_edge_zip_filepath}"
  filepath = "${var.lambda_edge_zip_filepath}"

#   filepath = "${var.cf_dist_lambda_edge_zip_filepath}"
}


