terraform {
  cloud {
    organization = "Ayodev"

    workspaces {
      name = "fargate-test-deploy"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

