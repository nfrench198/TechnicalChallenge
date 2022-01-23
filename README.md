# Master Terraform Template

This is a simple template that will deploy and configure a basic enviroment according to the Technical Challenge. The S3 Logging Bucket currently fails Checkov checks, this is a known issue with logging buckets and can be ignored.

## Getting started

No tfvars are used. For a full writeup please see "Documentatoin Overview.docx"
The latest version of Terraform v1.0.11 needs to be used for deployment.

To run this simply run:

```shell
terraform init

terraform apply
```