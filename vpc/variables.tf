variable "region" {
  type        = string
  description = "AWS region for VPC resources"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use for VPC creation"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones for subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "environment" {
  type        = string
  description = "Environment name for the VPC"
}
