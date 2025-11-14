############################################
# Providers for Helm and Kubernetes (EKS)
# Uses cluster data passed from main module
############################################

provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = var.cluster_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  # optional: set load_config_file = false if you don't want to merge with local kubeconfig
  # load_config_file = false
}

provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    token                  = var.cluster_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}
