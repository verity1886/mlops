terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.25" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.13" }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

resource "kubernetes_namespace" "infra_tools" {
  metadata {
    name = var.namespace
    labels = { "app.kubernetes.io/part-of" = "infra-tools" }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.infra_tools.metadata[0].name
  create_namespace = false

  values = [file("${path.module}/values/argocd-values.yaml")]

  timeout  = 1200
  atomic   = false
  cleanup_on_fail = false
}

