variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_version" {
  type        = string
  description = "EKS version"
}

variable "node_group_name" {
  type        = string
  description = "Name of the node group"
}


variable "environment" {
  type        = string
  description = "production"
}

variable "cluster_role_arn" { }

variable "node_role_arn" { }

variable "subnet_ids" { }