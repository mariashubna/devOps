resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "4.12.0" # приклад, можеш змінити

  namespace = var.namespace
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
