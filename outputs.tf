output "vpc_id" { 
    value = module.vpc.vpc_id 
}
output "eks_cluster_name" {
    value = module.eks.cluster_name
}
output "eks_cluster_endpoint" {
    value = module.eks.cluster_endpoint
}
output "eks_cluster_ca" {
    value = module.eks.cluster_ca_certificate
}
