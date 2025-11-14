resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  version          = "5.41.0"
  skip_crds        = true
  timeout          = 1200
  wait             = true
  replace          = true  

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_secret" "argocd_repo" {
  metadata {
    name      = "argocd-repo-creds"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
   
  }

  type = "Opaque"
}
