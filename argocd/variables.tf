variable "namespace" {
  type        = string
  default     = "infra-tools"
}

variable "argocd_chart_version" {
  type        = string
  default     = "6.7.15"
}

variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  default     = null
}
