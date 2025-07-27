output "cluster_name" {
  value = aws_eks_cluster.project_cluster.name
}

# You need to create an OIDC identity provider first
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.project_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.project_cluster.certificate_authority[0].data
}

output "node_group" {
  value = aws_eks_node_group.project_node_group
}
