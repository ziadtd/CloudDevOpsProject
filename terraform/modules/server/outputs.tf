output "jenkins_instance_id" {
  description = "ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Private IP of Jenkins instance"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_security_group_id" {
  description = "Security Group ID for Jenkins"
  value       = aws_security_group.jenkins.id
}

output "ssh_command" {
  description = "SSH command to connect to Jenkins"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "get_jenkins_password" {
  description = "Command to get Jenkins initial admin password"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}
