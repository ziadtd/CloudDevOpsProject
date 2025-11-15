# CloudDevOpsProject
End-to-end DevOps project with Docker, Kubernetes, Terraform, Ansible, Jenkins, and ArgoCD

# Step 1: GitHub Repository Setup

### 1. Create the Repository on GitHub

Go to [GitHub](https://github.com) and Create a new Repository 

### 2. Clone the Repository Locally

```bash
# Clone your repository
git clone https://github.com/ziadtd/CloudDevOpsProject.git

# Navigate into the directory
cd CloudDevOpsProject
```

### 3. Create Professional README.md

Create a comprehensive README for documentation in the root directory.

### 4. Create Initial Directory Structure

```bash
# Create the project directory structure
mkdir -p docker
mkdir -p kubernetes
mkdir -p terraform/{modules/{network,server},environments}
mkdir -p ansible/{playbooks,roles,inventory}
mkdir -p jenkins/shared-library/vars
mkdir -p argocd
mkdir -p docs
```

### 5. Commit and Push Initial Setup

```bash
# Add all files
git add .

# Commit with descriptive message
git commit -m "Initial repository setup with README, .gitignore, and directory structure"

# Push to GitHub
git push origin main
```

## Deliverables:

- Repository URL: `https://github.com/ziadtd/CloudDevOpsProject`

---

# Step 2: Containerization with Docker


### 1. Examine the Source Code

Clone the source code repository to understand the application structure:

```bash
cd ~/CloudDevOpsProject
git clone https://github.com/Ibrahim-Adel15/FinalProject.git temp-source
cd temp-source
ls -la

```

### 2. Copy Application Files to the Repository

```bash
cp -r tmp/FinalProject/app.py docker/
cp -r tmp/FinalProject/requirements.txt docker/
cp -r tmp/FinalProject/templates docker/
cp -r tmp/FinalProject/static docker/

# Clean up temporary
rm -rf tmp
```

### 3. Create the Dockerfile
```bash
# Navigate to docker directory
cd docker
# Create the Dockerfile
vim Dockerfile
```
```Dockerfile
#Stage 1
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2
FROM python:3.11-slim

ENV PATH=/home/appuser/.local/bin:$PATH

RUN useradd -m -u 1001 -s /bin/bash appuser

USER appuser

WORKDIR /app

COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

COPY  app.py .
COPY  templates/ ./templates/
COPY  static/ ./static/

EXPOSE 5000
```

### 4. Build to test the Image

```bash
# Build the image
docker build -t flask-app  .

# Run the container
docker run -d -p 5000:5000 --name flask-app flask-app

# Check if it's running
docker ps

# Test the application
curl http://localhost:5000

# Access in browser
# Open http://localhost:5000
```

![image](flask-app.png)

### 5. Image Inspection

```bash
# View image details
docker image inspect flask-app

# Check image size
docker images | grep flask-app

```

### 6. Pushing to Registry

```bash
docker login

docker tag flask-app:latest ziadtd/flask-app:latest
docker tag flask-app:latest ziadtd/flask-app:v1.0

docker push ziadtd/flask-app:latest
docker push ziadtd/flask-app:v1.0
```

### 7. Stopping and Cleaning Up

```bash
docker stop flask-app

docker rm flask-app
docker rmi flask-app:latest
```

### 8. Commit to Repository

```bash
cd ~/CloudDevOpsProject
git add .
git commit -m "Step 3"
git push origin main
```
## Deliverables:

- Docker Image: `https://hub.docker.com/repository/docker/ziadtd/flask-app/general`
- Dockerfile at: `https://github.com/ziadtd/CloudDevOpsProject/main/docker/Dockerfile`

---
# Step 3: Container Orchestration with Kubernetes


### 1. Prerequisites Check

First, ensure the necessary tools are installed:

```bash
# Check kubectl
kubectl version --client

# Check if you have kubeadm (testing) and access to EKS (deployment)
kubeadm version
aws eks list-clusters
```

### 3. Create Kubernetes Manifests

`namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ivolve
  labels:
    name: ivolve
    environment: production
    project: clouddevops
```
`configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: flask-app-config
  namespace: ivolve
  labels:
    app: flask-app
data:
  APP_PORT: "5000"
```

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: ivolve
  labels:
    app: flask-app
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
        version: v1.0.0
    spec:
      containers:
      - name: flask-app
        image: ziadtd/flask-app:v1.0  
        imagePullPolicy: Always
        ports:
        - name: http
          containerPort: 5000
          protocol: TCP
        
        envFrom:
        - configMapRef:
            name: flask-app-config
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        
        livenessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        
        # Security context
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
        
      # Restart policy
      restartPolicy: Always
```

`service-clusterip.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
  namespace: ivolve
  labels:
    app: flask-app
spec:
  type: ClusterIP
  selector:
    app: flask-app
  ports:
  - name: http
    port: 80
    targetPort: 5000
    protocol: TCP
```

`service-nodeport.yaml` for testing

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
  namespace: ivolve
spec:
  type: NodePort
  selector:
    app: flask-app
  ports:
  - port: 80
    targetPort: 5000
    nodePort: 30012
```

`hpa.yaml`
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
  namespace: ivolve
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

`ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-app-ingress
  namespace: ivolve
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flask-app-service
            port:
              number: 80
```


### 4. Deploy to Kubeadm to test:

```bash

kubectl apply -f namespace.yaml

# Apply all other resources
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service-nodeport.yaml
kubectl apply -f hpa.yaml

kubectl get all -n ivolve
```

---

### 5. Test the Deployment

```bash
# Check if pods are running
kubectl get pods -n ivolve

# Check services
kubectl get svc -n ivolve





# Test with curl
curl < worker-node >:30012

# View logs
kubectl logs -f deployment/flask-app -n ivolve
```

---

### 9. Commit to Repository

```bash
cd ~/CloudDevOpsProject
git add .
git commit -m "Step 3"
git push origin main
```

## Deliverables:

- Kubernetes Yaml files at: `https://github.com/ziadtd/CloudDevOpsProject/blob/main/kubernetes/`

---

# Step 4: Infrastructure Provisioning with Terraform

### 1. Prerequisites

```bash
# Check Terraform installation
terraform version

# Verify AWS CLI
aws --version

# Configure AWS credentials by copying the deatails from the AWS CLI Learner Lab into ~/.aws/credentials

# Verify credentials
aws sts get-caller-identity
```

---
### 2. Create  Directory Structure 

```bash
mkdir -p modules/{network,server,eks}
```

### 3. Create Root Configuration Files

In the root direcory create:

`provider.tf`

```hcl
terraform { #Version Pinning
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


   backend "s3" {
     bucket         = "ziad-terrafom-backend-bucket"
     key            = "terraform/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
   }
}

provider "aws" {
  region = var.aws_region
}
```

`variables.tf`

```hcl

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
  default     = "vockey"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
  default     = "EMR_EC2_DefaultRole"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into Jenkins"
  type        = string
  default     = "0.0.0.0/0"  # Preferably only a specified IP range
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
```

`outputs.tf`

```hcl
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
```

`main.tf`

```hcl
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

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  common_tags          = var.common_tags
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
```
### 4. Create Network Module Configuration Files

`main.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
```

`variables.tf`

```hcl
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
```

`outputs.tf`

```hcl
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
[ziad@master network]$
[ziad@master network]$ cat outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "network_acl_id" {
  description = "ID of the Network ACL"
  value       = aws_network_acl.main.id
}
```

#### Note: The CloudWatch Functionality was limited due to AWS Learner Lab Limited permissions
So Resources such as: Flow Logs, Log Groups, SNS Topics, CloudWatch Alarams and Metrics were not created
The only available CloudWatch functionality is the Dashboard

### 5. Create Jenkins Server Module Configuration Files

`main.tf`

```hcl
resource "aws_security_group" "jenkins" {
  name_prefix = "${var.project_name}-${var.environment}-jenkins-"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Jenkins web interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}-jenkins"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins-logs"
    }
  )
}

resource "aws_instance" "jenkins" {
  ami                    = var.amazon_linux_2_ami_id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = var.iam_instance_profile_name

  monitoring = true

  user_data = = templatefile("${path.module}/user-data.sh", {
    log_group_name = aws_cloudwatch_log_group.jenkins.name
  })
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }



  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [
    aws_cloudwatch_log_group.jenkins
  ]
}

resource "aws_cloudwatch_metric_alarm" "jenkins_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-jenkins-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Jenkins EC2 CPU utilization"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "jenkins_status_check" {
  alarm_name          = "${var.project_name}-${var.environment}-jenkins-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors Jenkins EC2 status checks"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }

  tags = var.common_tags
}
```

`variables.tf`

```hcl
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into Jenkins"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for Jenkins"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "amazon_linux_2_ami_id" {
  description = "AMI ID for Amazon Linux 2"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
```

`outputs.tf`

```hcl
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
```

`user-data.sh` 

```bash
#!/bin/bash
              set -e
              # Update system
              yum update -y
              # Install Java 11 (required for Jenkins)
              amazon-linux-extras install java-openjdk11 -y
              # Add Jenkins repository
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              # Install Jenkins
              yum install jenkins -y
              # Start and enable Jenkins
              systemctl start jenkins
              systemctl enable jenkins
              # Install Docker
              yum install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker jenkins
              usermod -aG docker ec2-user
              # Install Git
              yum install git -y
              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install
              rm -rf aws awscliv2.zip
              # Install CloudWatch agent
              wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
              rpm -U ./amazon-cloudwatch-agent.rpm
              # Create CloudWatch agent config
              cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWCONFIG'
              {
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/jenkins/jenkins.log",
                          "log_group_name": "${aws_cloudwatch_log_group.jenkins.name}",
                          "log_stream_name": "{instance_id}/jenkins.log"
                        }
                      ]
                    }
                  }
                },
                "metrics": {
                  "namespace": "Jenkins/EC2",
                  "metrics_collected": {
                    "mem": {
                      "measurement": [
                        {
                          "name": "mem_used_percent",
                          "rename": "MemoryUsedPercent",
                          "unit": "Percent"
                        }
                      ],
                      "metrics_collection_interval": 60
                    },
                    "disk": {
                      "measurement": [
                        {
                          "name": "used_percent",
                          "rename": "DiskUsedPercent",
                          "unit": "Percent"
                        }
                      ],
                      "metrics_collection_interval": 60,
                      "resources": ["/"]
                    }
                  }
                }
              }
              CWCONFIG
              # Start CloudWatch agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -s \
                -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
              # Wait for Jenkins and create info file
              sleep 30
              JENKINS_PASS=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Not yet available")
              cat > /home/ec2-user/jenkins-info.txt <<INFO
              Jenkins Installation Complete!
              ==============================
              Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080
              Initial Admin Password: $JENKINS_PASS
              To retrieve password later:
              sudo cat /var/lib/jenkins/secrets/initialAdminPassword
              INFO
              echo "Jenkins installation completed successfully!"
```

### 6. Create EKS Module Configuration Files

`main.tf`

```hcl
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.project_name}-${var.environment}-eks/cluster"
  retention_in_days = 7

}

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks"
  role_arn = var.eks_cluster_role_arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = var.public_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_security_group.eks_cluster
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.public_subnet_ids
  instance_types  = var.eks_node_instance_types

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_eks_cluster.main]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-node-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS node CPU utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "eks_node_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-node-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS node memory utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = var.common_tags
}
```

`variables.tf`

```hcl
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  type        = string
}

variable "eks_node_role_arn" {
  description = "ARN of the EKS node group IAM role"
  type        = string
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
```

`outputs.tf`

```hcl
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${aws_eks_cluster.main.arn != "" ? split(":", aws_eks_cluster.main.arn)[3] : ""} --name ${aws_eks_cluster.main.name}"
}
```

### 7. Deploy Infrastrructre

Make sure the S3 bucket is already created then:

```bash
# Initialize Terraform
terraform init

# Validate and format
terraform validate
terraform fmt -recursive

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan

#If all cnfigurations were correct: Apply complete! Resources: 23 added, 0 changed, 0 destroyed.
# View outputs
terraform output
```
On AWS Console check the creation of: 
1. Network Resources (9 resources):
- 1 VPC
- 1 Internet Gateway
- 2 Public Subnets (in us-east-1a and us-east-1b)
- 1 Route Table
- 2 Route Table Associations
- 1 Network ACL

2. Jenkins Server Resources (4 resources):

- 1 EC2 Instance (t3.medium with Jenkins)
- 1 Security Group (for Jenkins)
- 1 CloudWatch Log Group (for Jenkins logs)
- 2 CloudWatch Metric Alarms (CPU and Status Check)

3. EKS Resources (9 resources):

- 1 EKS Cluster
- 1 EKS Node Group
- 2 Security Groups (cluster and nodes)
- 3 Security Group Rules
- 1 CloudWatch Log Group (for EKS)
- 2 CloudWatch Metric Alarms (CPU and Memory)

Result:
```bash
configure_kubectl = "aws eks update-kubeconfig --region us-east-1 --name CloudDevOpsProject-dev-eks"
eks_cluster_endpoint = "https://6482D9F3F87BACF8F5E85F42153B55B1.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_id = "CloudDevOpsProject-dev-eks"
eks_cluster_name = "CloudDevOpsProject-dev-eks"
eks_cluster_security_group_id = "sg-0c03d4cc999a74eb0"
eks_node_group_id = "CloudDevOpsProject-dev-eks:CloudDevOpsProject-dev-node-group"
get_jenkins_password = "ssh -i vockey.pem ec2-user@54.81.198.5 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
internet_gateway_id = "igw-0041ce0d81eb21423"
jenkins_instance_id = "i-0c9bda63b5b4b5f6e"
jenkins_private_ip = "10.0.1.67"
jenkins_public_ip = "54.81.198.5"
jenkins_security_group_id = "sg-03613d8e14e189ac8"
jenkins_url = "http://54.81.198.5:8080"
network_acl_id = "acl-0776561fe4dc2a63e"
public_subnet_ids = [
  "subnet-0102089402a92574d",
  "subnet-0122041bca403e786",
]
ssh_command = "ssh -i vockey.pem ec2-user@54.81.198.5"
vpc_id = "vpc-07c4f313de9c1d6f2"

```

## 8. Commit to Repository
 
#### Note: All SSH keys (*.pem) are included in gitignore for security reasons

```bash
cd ~/CloudDevOpsProject
git add .
git commit -m "Step 4"
git push origin main
```

## Deliverables:

- Kubernetes Yaml files at: `https://github.com/ziadtd/CloudDevOpsProject/blob/main/kubernetes/`

---
