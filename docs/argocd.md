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
[`application.yaml`](../argocd/application.yaml)

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
