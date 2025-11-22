terraform { #Version Pinning
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  backend "s3" {
    bucket  = "ziad-terrafom-backend-bucket"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

