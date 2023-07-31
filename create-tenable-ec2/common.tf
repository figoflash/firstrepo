##################################################
# Provider/Backend/Workspace Check
##################################################
provider "aws" {
#  region = var.region
  region = "ap-east-1"
}

terraform {
  required_version = ">= 0.12.25"
  required_providers {
#    aws = "~> 2.61.0"
    aws = ">= 4.5.0"
  }
}

variable "owner" {
  description = "Team/person responsible for resources defined within this project"
  type        = string
  default = "team2"
}

variable "region" {
  description = "Region resources are being deployed to"
  type        = string
  default = "eu-west-2"
}

