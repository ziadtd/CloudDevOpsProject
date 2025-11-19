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

[namespace.yaml](../kubernetes/namespace.yaml)

[configmap.yaml](../kubernetes/configmap.yaml)

[deployment.yaml](../kubernetes/deployment.yaml)

[service-clusterip.yaml](../kubernetes/service-clusterip.yaml)

[service-nodeport.yaml](../kubernetes/service-nodeport.yaml)
#### For testing on kubeadm

[hpa.yaml](../kubernetes/hpa.yaml)

[ingress.yaml](../kubernetes/ingress.yaml)

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