output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.network.internet_gateway_id
}

output "network_acl_id" {
  description = "ID of the Network ACL"
  value       = module.network.network_acl_id
}

output "jenkins_instance_id" {
  description = "ID of the Jenkins EC2 instance"
  value       = module.server.jenkins_instance_id
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins instance"
  value       = module.server.jenkins_public_ip
}

output "jenkins_private_ip" {
  description = "Private IP of Jenkins instance"
  value       = module.server.jenkins_private_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = module.server.jenkins_url
}

output "jenkins_security_group_id" {
  description = "Security Group ID for Jenkins"
  value       = module.server.jenkins_security_group_id
}

output "ssh_command" {
  description = "SSH command to connect to Jenkins"
  value       = module.server.ssh_command
}

output "get_jenkins_password" {
  description = "Command to get Jenkins initial admin password"
  value       = module.server.get_jenkins_password
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.eks_cluster_security_group_id
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.eks_node_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = module.eks.configure_kubectl
}
