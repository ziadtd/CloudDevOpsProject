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
git clone https://github.com/Ibrahim-Adel15/FinalProject.git tmp
cd tmp
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
The Dockerfile is available in the Docker Directory
[Dockerfile](docker/Dcokerfile)


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

All Files are available in the Kubernetes Directory 

[namespace.yaml](kubernetes/namespace.yaml)

[configmap.yaml](kubernetes/configmap.yaml)

[deployment.yaml](kubernetes/deployment.yaml)

[service-clusterip.yaml](kubernetes/service-clusterip.yaml)

[service-nodeport.yaml](kubernetes/service-nodeport.yaml) 
#### For testing on kubeadm

[hpa.yaml](kubernetes/hpa.yaml)

[ingress.yaml](kubernetes/ingress.yaml)


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

[provider.tf](terraform/provider.tf)

[variables.tf](terraform/variables.tf)

[outputs.tf](terraform/outputs.tf)

[main.tf](terraform/main.tf)


### 4. Create Network Module Configuration Files

In the Modules direcory create a Network directory with:

[main.tf](terraform/modules/network/main.tf)

[variables.tf](terraform/modules/network/variables.tf)

[outputs.tf](terraform/modules/network/outputs.tf)

#### Note: The CloudWatch Functionality was limited due to AWS Learner Lab Limited permissions
So Resources such as: Flow Logs, Log Groups, SNS Topics, CloudWatch Alarms and Metrics were not created.
The only available CloudWatch functionality is the Dashboard


### 5. Create Jenkins Server Module Configuration Files

In the Modules direcory create a Server directory with:

[main.tf](terraform/modules/server/main.tf)

[variables.tf](terraform/modules/server/variables.tf)

[outputs.tf](terraform/modules/server/outputs.tf)

[user-data.sh](terraform/modules/server/user-data.sh)

### 6. Create EKS Module Configuration Files

In the Modules direcory create an EKS directory with:

[main.tf](terraform/modules/eks/main.tf)

[variables.tf](terraform/modules/eks/variables.tf)

[outputs.tf](terraform/modules/eks/outputs.tf)


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


## 8. Commit to Repository
 
#### Note: All SSH keys (*.pem) are included in gitignore for security reasons

```bash
cd ~/CloudDevOpsProject
git add .
git commit -m "Step 4"
git push origin main
```

## Deliverables:

- Terraform Files : `https://github.com/ziadtd/CloudDevOpsProject/blob/main/terraform/`

---
