# Terraform eks-ec2 module

## Local development

Create a role in the target AWS account that can be assumed by the Core AWS account, and attach the appropriate policies (TBD).

Supply the ARN of that role using the variable `assume_role_arn`.

## Feature toggle caveats

* New service broker table names causes table to be re-generated
* Service broker depends on KIAM. OK? Or `"${var.kiam_deploy ? ${module.eks_kiam.kiam_server_role_id} : ${var.servicebroker_iam_role}"`?
* `kiam_deploy = false` and `servicebroker_deploy = true` throws "MalformedPolicyDocument: invalid principal in policy" and an incomplete role ARN - but why anything at all, if kiam was not deployed?
* When using `count`, single-values will now be lists, and splatting must be used when referring to them. E.g. `"${element(concat(aws_iam_role.server_role.*.id, list("")), 0)}"`
  * Is immediately apparent when outputting from a module
  * May not be immediately apparent when used within the sub-module