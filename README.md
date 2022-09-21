
# Introduction

This stack illustrates how we can query S3 data using AWS Athena.


# Pre-requisites

1. AWS CLI. 
1. Terraform : The AWS resources are provisioned using terraform. 

Be aware that this small demo may cost you few cents. AWS Athena doesn't have any free tier. 


# Usage 

Before deploying the stack, make sure the `aws_cli_profile` is correct in the defaults.tfvars. Then, use terraform to deploy it.

The following command shows the list of resources that are about to be provisioned.
```
% terraform plan -out=out.tfplan -var-file=defaults.tfvars 
```

To apply those changes: 
```
% terraform apply "out.tfplan"
```

Use AWS Athena console to query the content of the S3 bucket.


# Clean up 

To clean everything created by this stack:

```
% terraform plan -destroy -var-file=defaults.tfvars -out=out.tfplan
% terraform apply "out.tfplan"
```

----
Braim (braimt@gmail.com)