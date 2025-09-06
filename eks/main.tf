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
    default = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 2
      instance_types   = ["t3.medium"]
      disk_size        = 20
      subnet_ids = var.private_subnet_ids
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
