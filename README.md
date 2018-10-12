# infrastructure-modules

Terraform modules for infrastructure

## Terraform Best Practices

### Terraform Files

main.tf
outputs.tf
vars.tf

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