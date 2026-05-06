
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"

    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.33.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.6"
    }
  }
}
