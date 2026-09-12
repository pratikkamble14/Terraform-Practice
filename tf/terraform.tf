terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }


  backend "s3" {
    bucket = "pk-terraf-state-bucket"
    key = "terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
  }
}

