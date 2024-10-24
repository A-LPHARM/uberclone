# Output the worker node role ARN
output "eks_worker_node_role_arn" {
  value = aws_iam_role.workernode.arn
}