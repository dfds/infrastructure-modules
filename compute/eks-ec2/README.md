# Terraform eks-ec2 module

## Local development

Create a role in the target AWS account that can be assumed by the Core AWS account, and attach the appropriate policies (TBD).

Supply the ARN of that role using the variable `assume_role_arn`.

Requires the use of Terraform remote state (at least for the cluster module), at the following path: `"${var.aws_region}/k8s-${var.eks_cluster_name}/cluster/terraform.tfstate"`.

## Feature toggle caveats

* Add description to all EKS/K8S main module variables
* New service broker table names causes table to be re-generated
* Service broker depends on KIAM. OK? Or `"${var.kiam_deploy ? ${module.eks_kiam.kiam_server_role_id} : ${var.servicebroker_iam_role}"`?
* `kiam_deploy = false` and `servicebroker_deploy = true` throws "MalformedPolicyDocument: invalid principal in policy" because KIAM output is blank when disabled
* When using `count`, single-values will now be lists, and splatting must be used when referring to them. E.g. `"${element(concat(aws_iam_role.server_role.*.id, list("")), 0)}"`
  * Is immediately apparent when outputting from a module
  * May not be immediately apparent when used within the sub-module
* Changes to certificate modules in main, causes certs to be recreated. Timed out destroying old certs (in use).