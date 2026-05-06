terraform {
  backend "s3" {
    bucket         = "ah.terraform.state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
    assume_role = {
      role_arn     = "arn:aws:iam::841602633529:role/Terraform"
      session_name = "terraform"
    }
  }
}

provider "aws" {
  region = local.region
  assume_role {
    role_arn     = "arn:aws:iam::841602633529:role/Terraform"
    session_name = "terraform"
  }
}
