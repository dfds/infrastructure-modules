[![QA Pipeline](https://github.com/dfds/infrastructure-modules/actions/workflows/qa.yml/badge.svg)](https://github.com/dfds/infrastructure-modules/actions/workflows/qa.yml)
[![Gitleaks](https://github.com/dfds/infrastructure-modules/actions/workflows/secret-detection.yml/badge.svg)](https://github.com/dfds/infrastructure-modules/actions/workflows/secret-detection.yml)
[![Trivy IAC with Quality Gate](https://github.com/dfds/infrastructure-modules/actions/workflows/trivy.yml/badge.svg)](https://github.com/dfds/infrastructure-modules/actions/workflows/trivy.yml)
[![TFLint](https://github.com/dfds/infrastructure-modules/actions/workflows/tflint.yml/badge.svg)](https://github.com/dfds/infrastructure-modules/actions/workflows/tflint.yml)

# infrastructure-modules

Terraform modules for AWS infrastructure.

Containers to run this: https://hub.docker.com/u/dfdsdk

## Terraform Best Practices

### Terraform Files

- main.tf
- outputs.tf
- vars.tf

### Terraform Module Folder Structure

We recommend a folder structure for Terraform modules like so:

```
module-category
 └ module-name
    └ README.md
    └ main.tf
    └ outputs.tf
    └ vars.tf
```

Example:
```
security
 └ iam-account-alias
    └ README.md
    └ main.tf
    └ outputs.tf
    └ vars.tf
 └ org-account
    └ README.md
    └ main.tf
    └ outputs.tf
    └ vars.tf
network
 └ ...
```

## Test/QA

### Find compatible AMI images

```bash
EKS_CLUSTER_VERSION=1.34
AWS_REGION=eu-west-1

aws ssm get-parameter --name /aws/service/eks/optimized-ami/$EKS_CLUSTER_VERSION/amazon-linux-2023/x86_64/standard/recommended/image_id --region $AWS_REGION --query "Parameter.Value" --output text
```

## Release process

Branch protection is not enabled on this repo. Instead we rely on release tags to ensure we do not commit straight to production.

Release tags are created automatically when merging to master branch. The release tag is calculated based on labels (release:najor, release:minor, release:patch or norelease). The norelease label is used when updating test cases or the QA environment, but not when updating the modules.

### Pre-Commit Hooks (Optional)

This repo defines Git pre-commit hooks intended for use with pre-commit.

- Install pre-commit. E.g. brew install pre-commit. https://pre-commit.com/#install
- Run `pre-commit install` in the repo.
- That’s it! Now every time you commit a code change (.tf file), the hooks in the hooks: config will execute.

### Credits

The general structure of these modules, file layout etc. are largely based on Gruntwork's recommendations. More specifically the blog posts:

* [Gruntwork blog: How to manage Terraform state](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa)
* [Gruntwork blog: How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
* [Gruntwork blog: How to use Terraform as a team](https://blog.gruntwork.io/how-to-use-terraform-as-a-team-251bc1104973)

Gruntwork's example repos, of both modules and live/input data, along with their README files have also proven very useful:

* [Github: gruntwork-io/terragrunt-infrastructure-live-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)
* [Github: gruntwork-io/terragrunt-infrastructure-modules-example](https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example)

To workaround some of Terraform's quirks and shortcomings:

* [Gruntwork blog: Terraform tips & tricks: loops, if-statements, and gotchas](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)

Other inspiration:

* https://www.ybrikman.com/writing/2017/10/13/reusable-composable-battle-tested-terraform-modules/
