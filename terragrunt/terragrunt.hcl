terraform {
  source = "../terraform"
}

inputs = {
  region = "us-west-2"
  cluster_name = "echo-server-cluster"
  cidr_block = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs = ["us-west-2a", "us-west-2b"]
  key_name = "ssh-key-pair"
  tags = {
    Name = "Andrey"
    Owner = "Nati"
    Department = "DevOps"
    Temp = "True"
  }
}
