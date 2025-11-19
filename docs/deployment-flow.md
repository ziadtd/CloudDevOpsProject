# Architecture Overview

This document describes the CloudDevOpsProject architecture: CI (Jenkins + GitHub Actions), CD (ArgoCD), DockerHub registry, Terraform-managed infra, and an EKS cluster hosting the application. Due to AWS Learner Lab limitations, the nginx ingress controller is exposed through a NodePort on an EKS worker node public IP (no LoadBalancer).

## System Diagram
(paste the Mermaid block here)

## Component Responsibilities
- Jenkins: build, scan, terraform interactions, push images to DockerHub.
- GitHub Actions: optional CI tasks.
- DockerHub: image registry.
- ArgoCD: GitOps CD syncing manifests to EKS.
- EKS: runs app, ingress, HPA.
- CloudWatch: logs and metrics.
- S3: Terraform remote state.

## Deployment flow summary

1. Code change: Developer pushes code or merges PR into main (or creates a tag).

2. CI Trigger: GitHub webhook triggers Jenkins and optionally GitHub Actions.

3. CI pipeline:
- Lint & unit tests run.
- Container image is built.
- Security scan (Trivy) runs.
- Image is tagged (vX.Y.Z, latest) and pushed to DockerHub.
- If required, Jenkins runs terraform plan and (with approvals) terraform apply to update infra. Terraform uses S3 for tfstate.
- Jenkins updates Kubernetes manifests (image tag) in the GitHub repo and pushes a commit or opens a PR.

4. CD (GitOps):
- ArgoCD monitors repo for manifest changes.
- On change, ArgoCD syncs resources to the EKS cluster (apply manifests).
- ArgoCD performs health checks and reports status; it can rollback if configured.

5. Traffic:
- External user hits the Worker Node public IP on the configured NodePort.
- nginx ingress (listening on that NodePort) routes to the appropriate service and pod.

6. Observability:
- EKS forwards logs and metrics to CloudWatch where dashboards and alarms are configured.

7. Notes:

- No DB is present.
- No external secret manager in use — secrets handled via k8s secrets or env files (lab-only approach).
- NodePort + public worker IP is chosen due to AWS Learner Lab restrictions.