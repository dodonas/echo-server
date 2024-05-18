variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-west-2"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "echo-server-eks-cluster"
}

variable "key_name" {
  description = "SSH key pair"
  default     = "ssh-key-pair"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Name        = "Andreyd"
    Owner       = "Nati"
    Department  = "DevOps"
    Temp        = "True"
  }
}
