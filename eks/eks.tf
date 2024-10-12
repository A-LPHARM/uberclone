resource "aws_eks_cluster" "k8s-production" {
  name            = local.cluster_name
  role_arn        = aws_iam_role.eksclusteriam.arn

  vpc_config {
    subnet_ids         = ["${aws_subnet.private_subnet.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]

   #Change Auth Mode from Config to EKS API
    access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

#latest version of the Amazon EKS optimized Amazon Linux AMI for a given EKS version by querying an Amazon provided SSM parameter#
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.k8s.version}/amazon-linux-2-gpu/recommended/release_version"
}


resource "aws_eks_node_group" "k8s-workernode" {
  cluster_name    = aws_eks_cluster.k8s-production.name
  node_group_name = "k8s-node"
  node_role_arn   = aws_iam_role.workernode.arn
  subnet_ids      = values(aws_subnet.private_subnet)[*].id

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
    Name = "${local.environment}-${local.cluster_name}"
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Retrieve EKS cluster details
data "aws_eks_cluster" "test" {
  name = aws_eks_cluster.k8s-production.name

  depends_on = [aws_eks_cluster.k8s-production]
}

# Retrieve EKS cluster authentication details
data "aws_eks_cluster_auth" "ephemeral" {
  name = aws_eks_cluster.k8s-production.name

  depends_on = [aws_eks_cluster.k8s-production]
}