output "eks_cluster_role_arn" {
  value = aws_iam_role.eksclusteriam.arn
}

output "eks_cluster_id" {
  value = aws_eks_cluster.k8s-production.id
}
