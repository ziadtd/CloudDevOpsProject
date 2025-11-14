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
