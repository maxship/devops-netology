#versions.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket         = "maxship-s3"
    key            = "terraform/key"
    region         = "eu-north-1"
    dynamodb_table = "s3-bucket-table"
  }
}