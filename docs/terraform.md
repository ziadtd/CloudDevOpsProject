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

[provider.tf](../terraform/provider.tf)

[variables.tf](../terraform/variables.tf)

[outputs.tf](../terraform/outputs.tf)

[main.tf](../terraform/main.tf)

### 4. Create Network Module Configuration Files

In the Modules direcory create a Network directory with:

[main.tf](../terraform/modules/network/main.tf)

[variables.tf](../terraform/modules/network/variables.tf)

[outputs.tf](../terraform/modules/network/outputs.tf)

#### Note: The CloudWatch Functionality was limited due to AWS Learner Lab Limited permissions

So Resources such as: Flow Logs, Log Groups, SNS Topics, CloudWatch Alarms and Metrics were not created.
The only available CloudWatch functionality is the Dashboard

### 5. Create Jenkins Server Module Configuration Files

In the Modules direcory create a Server directory with:

[`main.tf`](../terraform/modules/server/main.tf)

[`variables.tf`](../terraform/modules/server/variables.tf)

[`outputs.tf`](../terraform/modules/server/outputs.tf)

[`user-data.sh`](../terraform/modules/server/user-data.sh)

### 6. Create EKS Module Configuration Files

In the Modules direcory create an EKS directory with:

[`main.tf`](../terraform/modules/eks/main.tf)

[`variables.tf`](../terraform/modules/eks/variables.tf)

[`outputs.tf`](../terraform/modules/eks/outputs.tf)

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
kubectl apply -f ingress.yaml

kubectl get all -n ivolve
kubectl get pods -n ivolve

# Get node external IP
kubectl get nodes -o wide

# Access via NodePort
curl http://< NODE_EXTERNAL_IP >:30012
```
To access it using a URL:

#### Note: Due to restrictions on the AWS Learner Lab the LB couldn't be properly configured so a simple Ngnix Ingress Controller was used

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/aws/deploy.yaml

# Wait for the Ingress Contoller to be created (takes 2-3 minutes)
kubectl get svc -n ingress-nginx ingress-nginx-controller --watch

# Once EXTERNAL-IP appears:
kubectl get ingress -n ivolve
#Address Column shows App URL
#i.e. http://aa6202944f7f74fc69ce6fd97863eb02-23b5ff77e8883da9.elb.us-east-1.amazonaws.com/
```

Alternatively this is  be achieved by using terraform

 [`ingress.tf`](../terraform/ingress.tf)                    

 The URL is included in the terraform output:
 ```bash
 terraform apply
# After completion, Terraform prints:
# Outputs:
# ingress_controller_url = "http://a0d8d68e222db4048a6471bbcda9408f-43245493.us-east-1.elb.amazonaws.com/"
 ```
 This replaces the manual steps of applying the Ingress controller


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
