output "cluster_role_arn" {
  value = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  value = aws_iam_role.node_role.arn
}

output "external_dns_irsa_role_arn" {
  value = module.external_dns_irsa_role.iam_role_arn
}