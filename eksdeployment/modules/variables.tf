# Below is the variable block
variable "k8s_vpc_east_1_project" {
  description = "The project name for the east region VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "zone1_east" {
  description = "First availability zone for the us-east-1 region"
  type        = string
}

variable "zone2_east" {
  description = "Second availability zone for the us-east-1 region"
  type        = string
}

variable "zone1_west" {
  description = "First availability zone for the us-west-2 region"
  type        = string
}

variable "zone2_west" {
  description = "Second availability zone for the us-west-2 region"
  type        = string
}

variable "environment" {
  description = "The environment type (e.g., production, development)"
  type        = string
}

variable "iam_role_name" {
  type        = string
  description = "The name of the IAM role to create"
}

variable "cluster_name" {
  type        = string
  description = "The clustername"
}

variable "node_group_name" {
  type = string
  description = "the nodename"
}

variable "eks_worker_node_role_arn" { }

variable "private_subnet2_cidr" { }  

variable "private_subnet1_cidr" { }
