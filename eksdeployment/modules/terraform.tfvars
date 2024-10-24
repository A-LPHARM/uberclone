

# VPC and region configuration for east
vpc_cidr               = "10.0.0.0/16"
zone1_east             = "us-east-1a"
zone2_east             = "us-east-1b"
k8s_vpc_east_1_project = "k8s-project-east"

# VPC and region configuration for west
zone1_west = "us-west-2a"
zone2_west = "us-west-2b"

environment = "production"

iam_role_name = "eks-iam-role"

# cluster 

cluster_name = "k8s-cluster-production"

node_group_name = "k8s-node"

private_subnet1_cidr       = "172.16.2.0/24"
private_subnet2_cidr       = "172.16.4.0/24"