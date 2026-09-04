terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0" //Provider Version (CLOUD PROVIDER)
    }

    random = {
      source = "hashicorp/random" //Other provides (GENERATES RANDOM DIFERENT USE CASES)
      version = ">= 1.0" //Terrafrom core version
    }
  }
  required_version = ">= 1.0" // Terraform Core version
}

