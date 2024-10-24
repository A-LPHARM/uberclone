output "henryproject" {
    value = var.k8s-vpc-east-1-project
}

output "vpc_id" {
    value = aws_vpc.k8s-vpc-east-1.id
}

output "publicsubnet" {
    value = aws_subnet.publicsubnet.id
}

output "publicsubnet2" {
    value = aws_subnet.publicsubnet2.id
}

output "private_subnet_id1" {
  value = aws_subnet.privatesubnet1.id
}

output "private_subnet_id2" {
  value = aws_subnet.privatesubnet2.id
}

output "Internetgateway" {
    value = aws_internet_gateway.publicig
}