#
#
# @Braim T (braimt@gmail.com)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  profile = var.aws_cli_profile
  region  = "eu-west-1"


  default_tags {
    tags = {
      "Created_By"  = "Terraform",
      "Description" = "Demo to run SQL statements against files in S3 using AWS Athena"
    }
  }
}

