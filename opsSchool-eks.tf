provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "mid_course_eks"
}

module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "8.1.0"
  cluster_name           = local.cluster_name
  vpc_id                 = aws_vpc.vpc1.id
  subnets                =  "${aws_subnet.public.*.id}"
  
  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    consul_server = true
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.k8_node_instance_type
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.k8s.id]
    }
  ]
}