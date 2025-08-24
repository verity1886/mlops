module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id        = var.vpc_id
  subnet_ids    = var.subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access          = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns               = {}
    eks-pod-identity-agent = {}
    kube-proxy            = {}
    vpc-cni               = {}
  }
  
  eks_managed_node_groups = {
    cpu-nodes = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.micro"]
      disk_size        = 20
      subnet_ids = var.private_subnet_ids
    }

    gpu-nodes = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.small"]
      disk_size        = 20
      labels = { workload = "gpu" }
      subnet_ids = var.private_subnet_ids
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
