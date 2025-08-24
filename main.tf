locals {
  region      = var.region
  environment = var.environment
}

provider "aws" {
  region  = "us-east-1"
  profile = "ecr-user"
}

module "vpc" {
  source = "./vpc"

  region          = local.region
  aws_profile     = var.aws_profile
  vpc_name        = "${var.project_name}-vpc"
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  environment     = local.environment
}

module "eks" {
  source = "./eks"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  region      = local.region
  aws_profile = var.aws_profile
  cluster_name = "${var.project_name}-eks"
  environment  = local.environment
}
