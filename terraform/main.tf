# Get existing IAM roles
data "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_name
}

data "aws_iam_role" "eks_node_role" {
  name = var.eks_node_role_name
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  common_tags         = var.common_tags
}

module "server" {
  source = "./modules/server"

  project_name              = var.project_name
  environment               = var.environment
  jenkins_instance_type     = var.jenkins_instance_type
  key_name                  = var.key_name
  iam_instance_profile_name = var.iam_instance_profile_name
  allowed_ssh_cidr          = var.allowed_ssh_cidr
  vpc_id                    = module.network.vpc_id
  public_subnet_id          = module.network.public_subnet_ids[0]
  internet_gateway_id       = module.network.internet_gateway_id
  amazon_linux_2_ami_id     = data.aws_ami.amazon_linux_2.id
  common_tags               = var.common_tags
}


module "eks" {
  source = "./modules/eks"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.network.vpc_id
  public_subnet_ids       = module.network.public_subnet_ids
  eks_cluster_role_arn    = data.aws_iam_role.eks_cluster_role.arn
  eks_node_role_arn       = data.aws_iam_role.eks_node_role.arn
  eks_node_desired_size   = var.eks_node_desired_size
  eks_node_max_size       = var.eks_node_max_size
  eks_node_min_size       = var.eks_node_min_size
  eks_node_instance_types = var.eks_node_instance_types
  common_tags             = var.common_tags
}
