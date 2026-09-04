terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0" 
    }

    random = {
      source = "hashicorp/random" //Other provides (GENERATES RANDOM DIFERENT USE CASES)
      version = ">= 1.0" //Terrafrom core version
    }
  }
}

