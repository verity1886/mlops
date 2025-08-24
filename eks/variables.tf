variable "region" {
  type        = string
  description = "AWS region for EKS cluster"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use for EKS cluster creation"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "environment" {
  type        = string
  description = "Environment name for the EKS cluster"
}



variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of all subnet IDs for the EKS cluster (combination of public and private)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS node groups"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs (not used by EKS node groups)"
}

