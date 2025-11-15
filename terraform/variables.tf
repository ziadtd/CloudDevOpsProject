variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "CloudDevOpsProject"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "labuser"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
  default     = "EMR_EC2_DefaultRole"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into Jenkins"
  type        = string
  default     = "0.0.0.0/0" # Preferably only a specified IP range
}

variable "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  type        = string
  default     = "c185535a4804566l12219871t1w013607-LabEksClusterRole-2xMUC7YPoJf7"
}

variable "eks_node_role_name" {
  description = "Name of the EKS node group IAM role"
  type        = string
  default     = "c185535a4804566l12219871t1w013607837-LabEksNodeRole-aBGl3bofEA9J"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Jenkins-Infrastructure"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}
