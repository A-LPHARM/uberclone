# Output the cluster role ARN
output "iam_role_name" {
  value = aws_iam_role.eksclusteriam.arn
}