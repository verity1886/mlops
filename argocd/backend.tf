terraform {
  backend "s3" {
    bucket         = "vp-test-tf-states"
    key            = "argocd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    profile        = "ecr-user"
  }
}
