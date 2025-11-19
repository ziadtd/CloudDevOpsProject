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
[Dockerfile](docker/Dockerfile)

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

### 2. Create Directory Structure

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

[`main.tf`](terraform/modules/server/main.tf)

[`variables.tf`](terraform/modules/server/variables.tf)

[`outputs.tf`](terraform/modules/server/outputs.tf)

[`user-data.sh`](terraform/modules/server/user-data.sh)

### 6. Create EKS Module Configuration Files

In the Modules direcory create an EKS directory with:

[`main.tf`](terraform/modules/eks/main.tf)

[`variables.tf`](terraform/modules/eks/variables.tf)

[`outputs.tf`](terraform/modules/eks/outputs.tf)

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


### 8. Deploying K8s Configuration on EKS 

Now that the EKS cluster has been deployed using Terraform, the cluster can be used to deploy the application:

```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --region us-east-1 --name CloudDevOpsProject-dev-eks

kubectl get nodes

# Deploy the manifests

cd ~/CloudDevOpsProject/kubernetes
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service-clusterip.yaml
kubectl apply -f service-nodeport.yaml

kubectl get all -n ivolve
kubectl get pods -n ivolve

# Get node external IP
kubectl get nodes -o wide

# Access via NodePort
curl http://< NODE_EXTERNAL_IP >:30012
```
To access it using a URL:

#### Note: Due to restrictions on the AWS Learner LAB the LB couldn't be properly configured so a simple Ngnix Ingress Controller was used

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/aws/deploy.yaml

# Wait for the NLB to be created (takes 2-3 minutes)
kubectl get svc -n ingress-nginx ingress-nginx-controller --watch

# Once EXTERNAL-IP appears:
kubectl get ingress -n ivolve
#Address Column shows App URL
#i.e. http://aa6202944f7f74fc69ce6fd97863eb02-23b5ff77e8883da9.elb.us-east-1.amazonaws.com/
```

### 9. Commit to Repository

#### Note: All SSH keys (\*.pem) are included in gitignore for security reasons

```bash
cd ~/CloudDevOpsProject
git add .
git commit -m "Step 4"
git push origin main
```

## Deliverables:

- Terraform Files : `https://github.com/ziadtd/CloudDevOpsProject/blob/main/terraform/`

---

# Step 5: Configuration Management with Ansible

### 1. Prerequisites Check

```bash
# Check Ansible installation
ansible --version

# Verify AWS CLI is configured
aws sts get-caller-identity
```


### 2. Create Ansible Directory Structure

```bash
mkdir -p ansible/{playbooks,roles,inventory,group_vars}
mkdir -p ansible/roles/{common,java,docker,jenkins,git}/{tasks,handlers,templates}
```


### 3. Create Ansible Configuration

In the root Ansible Directory create these files:

[`ansible.cfg`](ansible/ansible.cfg)

Then in the Inventroy dierctory create:

[`aws_ec2.yaml`](ansible/inventory/aws_ec2.yaml)


### 4: Create Group Variables

In the group_vars Directory create:

[`all.yaml`](ansible/group_vars/all.yaml)


### 5. Create Ansible Roles

In the Roles Directory create the following files:

1. In the Common subdirectory create 
[`tasks/main.yaml`](ansible/roles/common/tasks/main.yaml)

2. In the Java subdirectory create 
[`tasks/main.yaml`](ansible/roles/java/tasks/main.yaml)

3. In the Git subdirectory create 
[`tasks/main.yaml`](ansible/roles/git/tasks/main.yaml)

4. In the Docker subdirectory create 
[`tasks/main.yaml`](ansible/roles/docker/tasks/main.yaml)

4. In the Jenkins subdirectory create 
[`tasks/main.yaml`](ansible/roles/jenkins/tasks/main.yaml)


### 6. Create Main Playbook

In the Playbooks directory create:
[`jenkins-setup.yaml`](ansible/playbooks/jenkins-setup.yaml)


### 7. Create Verification Playbook

In the Playbooks directory create:
[`verify.yaml`](ansible/playbooks/verify.yaml)


### 8. Create Requirements File

In the Root directory create:
[`requirements.txt`](ansible/requirements.txt)


### 9. Create Helper Script

create te script to check hosts connection andrun the playbook:

[`run-ansible.sh`](ansible/run-ansible.sh)


### 10. Install Dependencies

```bash
pip3 install -r requirements.txt

ansible --version
python3 -c "import boto3; print('boto3:', boto3.__version__)"
```


### 11. Test Dynamic Inventory

```bash
# Make scripts executable
chmod +x run-ansible.sh 

ansible-inventory -i ./inventory/aws_ec2.yaml  --graph

# Test connectivity
ansible all  -m ping
```


### 12. Run Ansible Playbook

```bash
# Dry run first (recommended)
ansible-playbook playbooks/jenkins-setup.yaml --check

#Then run the script
./run-ansible.sh

# Or run manually
ansible-playbook playbooks/jenkins-setup.yaml

# Run with verbose output (for debugging)
ansible-playbook playbooks/jenkins-setup.yaml -vvv
```


## Step 13: Verify Installation

```bash
# Run verification playbook
ansible-playbook playbooks/verify.yaml

# SSH into Jenkins server to check
ssh -i ../terraform/vockey.pem ec2-user@< JENKINS_IP >

# On Jenkins server, check:
cat /home/ec2-user/jenkins-info.txt
cat /home/ec2-user/ansible-summary.txt
sudo systemctl status jenkins
sudo systemctl status docker
docker --version
java -version
git --version
```

## Step 14: Commit to Repository

#### Note: All SSH keys (\*.pem) are included in gitignore for security reasons

```bash
cd ~/CloudDevOpsProject
echo "ansible.log" >> .gitignore
git add .
git commit -m "Step 5"
git push origin main
```

## Deliverables:

- Ansible Modules and Inventory Files : `https://github.com/ziadtd/CloudDevOpsProject/blob/main/ansible/`

---

# Step 6: Continuous Integration with Jenkins

### 1. Access Jenkins

```bash
# Get Jenkins URL from Terraform
cd ~/CloudDevOpsProject/terraform
terraform output jenkins_url

# Get Jenkins Public IP from Terraform
terraform output jenkins_public_ip

# Get initial admin password
ssh -i ~/CloudDevOpsProject/terraform/vockey.pem ec2-user@< jenkins_public_ip > "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
#Output: 7c...4a

# Or check the info file created by Ansible Jenkins Role
ssh -i ~/.ssh/vockey.pem ec2-user@< jenkins_public_ip > "cat /home/ec2-user/jenkins-info.txt"
```

Open Jenkins in browser: `http://< jenkins_public_ip >:8080`


### 2. Initial Jenkins Setup

1. Enter initial admin password
2. Select "Install suggested plugins"
3. Create first admin user
4. Keep default Jenkins URL
5. Click "Start using Jenkins"


Go to: Manage Jenkins → Plugins → Available plugins

Search and install:
- Docker Pipeline
- Docker
- Kubernetes CLI
- Pipeline: AWS Steps
- Git Parameter
- Configuration as Code


### 3. Configure Jenkins Credentials

Go to: Manage Jenkins → Credentials → System → Global credentials → Add Credentials

1. DockerHub Credentials

- **Kind**: Username with password
- **Username**: DockerHub username
- **Password**: DockerHub password 
- **ID**: `dockerhub-credentials`
- **Description**: DockerHub Registry Credentials

2. GitHub Credentials

- **Kind**: Username with password 
- **Username**: GitHub username
- **Password**: GitHub Personal Access Token
- **ID**: `github-credentials`
- **Description**: GitHub Credentials

3. Kubeconfig

- **Kind**: Secret file
- **File**: Upload your kubeconfig file
- **ID**: `kubeconfig`
- **Description**: Kubernetes Config


### 4. Create Shared Library Structure

```bash
# Create shared library structure
mkdir -p jenkins/shared-library/vars
mkdir -p jenkins/shared-library/src
mkdir -p jenkins/shared-library/resources
```


### 5. Create Shared Library Functions

In the vars subdirectory create:

[`dockerBuild.groovy`](jenkins/shared-library/vars/dockerBuild.groovy)

[`trivyScan.groovy`](jenkins/shared-library/vars/trivyScan.groovy)

[`dockerPush.groovy`](jenkins/shared-library/vars/dockerPush.groovy)

[`dockerCleanup.groovy`](jenkins/shared-library/vars/dockerCleanup.groovy)

[`updateManifests.groovy`](jenkins/shared-library/vars/updateManifests.groovy)

[`gitPushChages.groovy`](jenkins/shared-library/vars/gitPushChages.groovy)


### 6. Create Main Jenkinsfile

In the Jenkins Directory create:

[`Jenkinsfile`](jenkins/Jenkinsfile)

### 7. Create Jenkins Pipeline Job

1. Go to: Manage Jenkins → System
2. Scroll to Global Pipeline Libraries
3. Click Add
4. Configure:
   - **Name**: `shared-library`
   - **Default version**: `main`
   - **Retrieval method**: Modern SCM
   - **Source Code Management**: Git
   - **Project Repository**: `https://github.com/ziadtd/CloudDevOpsProject.git`
   - **Library Path**: `jenkins/shared-library`
5. Click **Save**

1. Go to Jenkins Dashboard
2. Click **New Item**
3. Enter name: `flask-app-ci-pipeline`
4. Select **Pipeline**
5. Click **OK**

**General Settings:**
- Check "GitHub project"
- Project url: `https://github.com/ziadtd/CloudDevOpsProject`
- Check "Discard old builds"
  - Max # of builds to keep: 10

**Build Triggers:**
- Check "GitHub hook trigger for GITScm polling"

**Pipeline Configuration:**
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/ziadtd/CloudDevOpsProject.git`
- **Credentials**: Select GitHub credentials
- **Branch**: `*/main`
- **Script Path**: `jenkins/Jenkinsfile`

Click **Save**


### 8. Configure GitHub Webhook

1. Go to repository on GitHub
2. Click Settings → Webhooks → Add webhook
3. Configure:
   - **Payload URL**: `http://< jenkins_public_ip >:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Which events**: "Just the push event"
   - Active
4. Click **Add webhook**


### 9. Commit to Repository

```bash
cd ~/CloudDevOpsProject

# Add all Jenkins files
git add .

# Commit
git commit -m "Step 6"

# Push
git push origin main
```


### 10. Run the first Build Manually 

In the Jenkins UI, **click the flask-app-ci-pipeline** item and click **Build Now** to start the first build

## Deliverables:
- Jenkinsfile at: `https://github.com/ziadtd/CloudDevOpsProject/blob/main/jenkins/Jenkinsfile`
- Shared Library Directory (vars): `https://github.com/ziadtd/CloudDevOpsProject/blob/main/jenkins/shared-library/vars`

---

# Alternate Step 6: Continuous Integration with Github Actions

### 1.  Add DockerHub Token

Go to [DockerHub Account Settings](https://hub.docker.com/settings/security) and generate a new Access Token

In the GitHub repo, go to: **Settings** → **Secrets and variables** → **Actions**
Click **New repository secret**
   - Name: `DOCKERHUB_TOKEN`
   - Value: Paste DockerHub token
Click **Add secret**

### Create The Workflow File

In the repo create [`pipeline.yaml`](.github/workflows/pipeline.yaml)


Then to trigger the Pipeline **Push a tag**:
   ```bash
   git tag v6.5
   git push origin v6.5
   ```

## Deliverables 
Github Pipeline File: at: `https://github.com/ziadtd/CloudDevOpsProject/blob/main/.github/workflows/pipeline.yaml`

---

# Step 7: Continuous Deployment with ArgoCD

### 1. Ensure kubectl is Configured

```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --region us-east-1 --name CloudDevOpsProject-dev-eks

# Verify connection
kubectl get nodes
kubectl get namespaces
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Check installation
kubectl get pods -n argocd
```

### 3. Access ArgoCD UI

```bash
# Patch service to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the NodePort
kubectl get svc argocd-server -n argocd
```

Access at: `http://< NODE_PUBLIC_IP >:31037`


### 4. Get ArgoCD Admin Password

```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

**Login:**
- Username: `admin`
- Password: (from above command)

### 5. Install ArgoCD CLI 

```bash
# Download ArgoCD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Make executable
chmod +x argocd

# Move to PATH
sudo mv argocd /usr/local/bin/

# Verify installation
argocd version --client
```

### 6. Login to ArgoCD via CLI

```bash
# Login 
argocd login < NODE_PUBLIC_IP >:30183 --username admin --insecure
#Enter Admin Password
```

### 7. Create ArgoCD Application Manifest

In the ArgoCD direcotry create
[`application.yaml`](argocd/application.yaml)

### 8. Deploy ArgoCD Application

```bash
# Apply ArgoCD application
kubectl apply -f application.yaml

# Check application status
argocd app get flask-app
```

### 10. Verify Deployment

```bash
# Check if app is synced
argocd app get flask-app

# Check pods in ivolve namespace
kubectl get pods -n ivolve

# Check services
kubectl get svc -n ivolve

# Get application URL 
kubectl get ingress -n ivolve
#Address Column shows App URL

# Access the app
curl http://APP_URL
```

### 11. Test GitOps Workflow

Change Source Directory

```bash
git add src/
git commit -m "New Release"
git push origin main
git tag v7
git push origin v7
```

