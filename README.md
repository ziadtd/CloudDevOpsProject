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
## Deliverables:

- Docker Image: `https://hub.docker.com/repository/docker/ziadtd/flask-app/general`
