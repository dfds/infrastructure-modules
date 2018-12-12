# Terraform eks-ec2 module

## Local development

Create a role in the target AWS account that can be assumed by the Core AWS account, and attach the appropriate policies (TBD).

Supply the ARN of that role using the variable `assume_role_arn`.