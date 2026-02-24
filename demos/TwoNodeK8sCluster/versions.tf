terraform {
  cloud {
    organization = "cloud-computing-gdl"
    workspaces {
      name = "TwoNodeK8sCluster"
    }
  }

  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
