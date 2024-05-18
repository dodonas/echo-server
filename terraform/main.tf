
# Define the provider, in our case AWS
provider "aws" {
  region = var.region
}

# Define the VPC module, which will create the VPC, subnets, route tables, etc.
# public_subnets is a list of CIDRs for the public subnets
# CIDR notation is used to define the range of IP addresses in the subnet in a compact format
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name           = var.vpc_name
  cidr           = var.vpc_cidr
  azs            = var.availability_zones
  public_subnets = var.public_subnets
  tags           = var.tags
}

# Elastic Kubernetes Service (EKS) module is used for deploying and managing our echo-server-cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_endpoint_public_access = true

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }


  tags = var.tags
}
