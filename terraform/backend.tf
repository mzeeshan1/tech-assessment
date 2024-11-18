terraform {
  backend "s3" {
    bucket         = "ss.tf.state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "sosafe-tech-assessment-remote-state"
    assume_role = {
      role_arn     = "arn:aws:iam::533266993905:role/Terraform"
      session_name = "terraform"
    }
  }
}

provider "aws" {
  region = local.region
  assume_role {
    role_arn     = "arn:aws:iam::533266993905:role/Terraform"
    session_name = "terraform"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--role-arn", "arn:aws:iam::533266993905:role/Terraform"]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--role-arn", "arn:aws:iam::533266993905:role/Terraform"]
  }
}

provider "datadog" {
  api_key = local.datadog_api_key
  api_url = "https://api.datadoghq.eu/"
  app_key = local.datadog_app_key
}
