# create vpc
module "vpc-us-east-1" {
    source = "./vpc-us-east-1"
    k8s-vpc-east-1-project     = var.k8s_vpc_east_1_project
    vpc_cidr                   = var.vpc_cidr
    private_subnet1_cidr       = var.private_subnet1_cidr
    private_subnet2_cidr       = var.private_subnet2_cidr
    zone1_east                 = var.zone1_east
    zone2_east                 = var.zone2_east
    environment                = var.environment            
    providers = {
    aws = aws.us-east-1
  }
}


module "vpc-us-west-2" {
    source = "./vpc-us-west-2"
    k8s-vpc-east-1-project     = var.k8s_vpc_east_1_project
    vpc_cidr                   = var.vpc_cidr
    private_subnet1_cidr       = var.private_subnet1_cidr
    private_subnet2_cidr       = var.private_subnet2_cidr
    zone1_west                 = var.zone1_west
    zone2_west                 = var.zone2_west
    environment                = var.environment  

    providers = {
    aws = aws.us-west-2
  }
}

module "clusteriam" {
  source = "./clusteriam"
  iam_role_name = var.iam_role_name
}

module "workeriam" {
  source = "./workeriam"
  eks_worker_node_role_arn = var.eks_worker_node_role_arn
}

module "eks_cluster_us_east_1" {
  source              = "./eks"  # Path to your module
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.clusteriam.iam_role_name
  node_role_arn       = module.workeriam.eks_worker_node_role_arn
  subnet_ids          = [module.vpc-us-east-1.private_subnet_id1, module.vpc-us-east-1.private_subnet_id2]
  eks_version         = "1.26"
  node_group_name     = var.node_group_name
  environment         = var.environment

  providers = {
    aws = aws.us-east-1
  }
}


module "eks_cluster_us_west_1" {
  source              = "./eks-us-west-2"  # Path to your module
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.clusteriam.iam_role_name
  node_role_arn       = module.workeriam.eks_worker_node_role_arn
  subnet_ids          = [module.vpc-us-west-2.private_subnet_id1, module.vpc-us-west-2.private_subnet_id2]
  eks_version         = "1.26"
  node_group_name     = var.node_group_name
  environment         = var.environment

   providers = {
    aws = aws.us-west-2
  }
}