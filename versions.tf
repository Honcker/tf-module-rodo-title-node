terraform {

  required_version = "~>1.3"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.28"
      configuration_aliases = [aws.us-east-1, aws.dns]
    }
  }
}
