terraform {
  backend "s3" {
    bucket         = "vp-test-tf-states"
    key            = "root/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    profile        = "ecr-user"
  }
}
