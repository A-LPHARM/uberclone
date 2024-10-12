output "endpoint" {
  value = aws_eks_cluster.k8s-production.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.k8s-production.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.k8s-production.name
}