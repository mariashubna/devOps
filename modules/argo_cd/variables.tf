############################################
# Variables for argo_cd module
############################################

# --- EKS cluster info for providers ---
variable "cluster_name" {
  description = "EKS cluster name used for kubernetes/helm providers"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "cluster_token" {
  description = "EKS cluster auth token"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

# --- Git repository info for ArgoCD ---
variable "repo_url" {
  description = "Git repository URL to be added to Argo CD (SSH or HTTPS)"
  type        = string
  default     = ""
}

variable "repo_type" {
  description = "Type of repository: git or helm"
  type        = string
  default     = "git"
}

variable "repo_username" {
  description = "If using HTTP Basic auth for Git, username"
  type        = string
  default     = ""
  nullable    = true
}

variable "repo_password" {
  description = "If using HTTP Basic auth for Git, password (stored in k8s secret)"
  type        = string
  default     = ""
  nullable    = true
  sensitive   = true
}

variable "repo_ssh_private_key" {
  description = "If using SSH access to repo — private key content"
  type        = string
  default     = ""
  nullable    = true
  sensitive   = true
}

variable "repo_insecure" {
  description = "If true, add insecureIgnoreHostKey (for demo/testing only)"
  type        = bool
  default     = false
}
