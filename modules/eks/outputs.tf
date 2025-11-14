# modules/eks/eks.tf
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.name
}

# outputs.tf
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}
