#
#
# @Braim T (braimt@gmail.com)


#
# 
variable "aws_cli_profile" {
  type = string
}

#
# 
variable "resource_prefix" {
  type = string
}


locals {
  # account number is added to avoid duplicates in bucket names.
  bucket_name = format("%s-s3-athena-simple-select-%s", var.resource_prefix, data.aws_caller_identity.me.account_id)
}