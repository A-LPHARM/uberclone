# Create EKS Cluster
resource "aws_eks_cluster" "k8s-production" {
  provider = aws.us-east-1
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  vpc_config {
    subnet_ids = var.subnet_ids 
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]

  # Access configuration
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# Get the latest Amazon EKS AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  provider = aws.us-east-1
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2-gpu/recommended/release_version"
}

# EKS Node Group
resource "aws_eks_node_group" "k8s-workernode" {
  provider = aws.us-east-1
  cluster_name    = aws_eks_cluster.k8s-production.name
  node_group_name = var.node_group_name
  version         = aws_eks_cluster.k8s-production.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  capacity_type  = "SPOT"

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.environment}-${var.cluster_name}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Get EKS Cluster details
data "aws_eks_cluster" "test" {
  provider = aws.us-east-1
  name = aws_eks_cluster.k8s-production.name
}

# Get EKS Cluster authentication details
data "aws_eks_cluster_auth" "ephemeral" {
  provider = aws.us-east-1
  name = aws_eks_cluster.k8s-production.name
}
