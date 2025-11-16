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

### 8. Commit to Repository

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
#  حوار  hosts: و الديناميك عامة 
## الجروبز و الحاجات دي بس لو تمام كمل عادي بقى عشان هو شغال اصلا في الجيت
### 1. Prerequisites Check

```bash
# Check Ansible installation
ansible --version

# Verify AWS CLI is configured
aws sts get-caller-identity
```

### 2. Create Ansible Directory Structure

```bash
mkdir -p ansible/{playbooks,roles,inventory,group_vars,host_vars}
mkdir -p ansible/roles/{common,java,docker,jenkins,git}/{tasks,handlers,templates}
```

### 3. Create Ansible Configuration

`ansible.cfg`

```ini
[defaults]
# Inventory
inventory = inventory/aws
host_key_checking = False
remote_user = ec2-user
private_key_file = ../terraform/vockey.pem

# Output
stdout_callback = yaml
bin_ansible_callbacks = True

# Performance
forks = 10
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 3600

# Roles
roles_path = roles

# Logging
log_path = ansible.log

# SSH
timeout = 30
remote_tmp = /tmp/.ansible-${USER}/tmp

[inventory]
enable_plugins = aws_ec2, host_list, yaml, ini, auto

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

In the Inventroy dierctory create:
`hosts.ini`

```ini
[jenkins]
jenkins-server ansible_host=<54.81.198.5> ansible_user=ec2-user ansible_ssh_private_key_file=../terraform/vockey.pem

[jenkins:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 4: Create Group Variables

In the group_vars Directory create:

`all.yaml`

```yaml
---
# Global variables for all hosts

# System Configuration
timezone: "UTC"
locale: "en_US.UTF-8"

# User Configuration
admin_users:
  - ec2-user
  - jenkins

# Package Repository URLs
jenkins_repo_url: "https://pkg.jenkins.io/redhat-stable/jenkins.repo"
jenkins_repo_key_url: "https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key"

# Java Configuration
java_version: "java-11-openjdk"
java_packages:
  - "java-11-openjdk"
  - "java-11-openjdk-devel"

# Docker Configuration
docker_packages:
  - docker
docker_users:
  - ec2-user
  - jenkins
docker_compose_version: "2.23.0"

# Git Configuration
git_packages:
  - git
  - git-core

# Jenkins Configuration
jenkins_version: "latest"
jenkins_port: 8080
jenkins_home: "/var/lib/jenkins"
jenkins_admin_username: "admin"
jenkins_plugins:
  - git
  - docker-workflow
  - pipeline-aws
  - kubernetes
  - kubernetes-cli
  - ansible
  - blueocean
  - configuration-as-code
  - job-dsl
  - workflow-aggregator
  - credentials-binding
  - ssh-agent

# AWS Configuration
aws_region: "us-east-1"
aws_cli_version: "2"

# Security
disable_selinux: false
enable_firewall: false

# Monitoring
enable_cloudwatch_agent: true
```

### 5. Create Ansible Roles

In the Roles Directory create the following files:

roles/common/tasks/main.yaml

```yaml
---
# Common role - System updates and basic configuration

- name: Update all packages
  yum:
    name: "*"
    state: latest
    update_cache: yes
  tags:
    - common
    - updates

- name: Install EPEL repository
  yum:
    name: epel-release
    state: present
  tags:
    - common
    - repos

- name: Install useful system packages
  yum:
    name:
      - wget
      - curl
      - vim
      - unzip
      - tar
      - net-tools
      - yum-utils
      - device-mapper-persistent-data
      - lvm2
    state: present
  tags:
    - common
    - packages

- name: Set timezone
  timezone:
    name: "{{ timezone }}"
  tags:
    - common
    - timezone

- name: Disable SELinux (if configured)
  selinux:
    state: disabled
  when: disable_selinux | bool
  tags:
    - common
    - selinux

- name: Create admin users home directories
  file:
    path: "/home/{{ item }}"
    state: directory
    mode: "0755"
  loop: "{{ admin_users }}"
  when: item != 'root'
  tags:
    - common
    - users

- name: Ensure SSH directory exists
  file:
    path: "/home/ec2-user/.ssh"
    state: directory
    mode: "0700"
    owner: ec2-user
    group: ec2-user
  tags:
    - common
    - ssh
```

roles/java/tasks/main.yaml

```yaml
---
# Java role - Install and configure Java

- name: Install Java OpenJDK 11
  yum:
    name: "{{ java_packages }}"
    state: present
  tags:
    - java
    - packages

- name: Set JAVA_HOME environment variable
  lineinfile:
    path: /etc/environment
    line: "JAVA_HOME=/usr/lib/jvm/java-11-openjdk"
    create: yes
  tags:
    - java
    - environment

- name: Add Java to PATH in profile
  lineinfile:
    path: /etc/profile.d/java.sh
    line: "export PATH=$JAVA_HOME/bin:$PATH"
    create: yes
    mode: "0644"
  tags:
    - java
    - environment

- name: Verify Java installation
  command: java -version
  register: java_version_output
  changed_when: false
  tags:
    - java
    - verify

- name: Display Java version
  debug:
    var: java_version_output.stderr_lines
  tags:
    - java
    - verify
```

roles/git/tasks/main.yaml

```yaml
---
# Git role - Install and configure Git

- name: Install Git packages
  yum:
    name: "{{ git_packages }}"
    state: present
  tags:
    - git
    - packages

- name: Configure Git global settings for ec2-user
  git_config:
    name: "{{ item.name }}"
    value: "{{ item.value }}"
    scope: global
  loop:
    - { name: "user.name", value: "Jenkins CI" }
    - { name: "user.email", value: "jenkins@clouddevops.local" }
    - { name: "core.editor", value: "vim" }
    - { name: "pull.rebase", value: "false" }
  become: yes
  become_user: ec2-user
  tags:
    - git
    - config

- name: Configure Git global settings for jenkins user
  git_config:
    name: "{{ item.name }}"
    value: "{{ item.value }}"
    scope: global
  loop:
    - { name: "user.name", value: "Jenkins CI" }
    - { name: "user.email", value: "jenkins@clouddevops.local" }
    - { name: "core.editor", value: "vim" }
    - { name: "pull.rebase", value: "false" }
  become: yes
  become_user: jenkins
  tags:
    - git
    - config

- name: Verify Git installation
  command: git --version
  register: git_version_output
  changed_when: false
  tags:
    - git
    - verify

- name: Display Git version
  debug:
    var: git_version_output.stdout
  tags:
    - git
    - verify
```

roles/docker/tasks/main.yaml

```yaml
---
# Docker role - Install and configure Docker

- name: Install Docker packages
  yum:
    name: "{{ docker_packages }}"
    state: present
  tags:
    - docker
    - packages

- name: Start and enable Docker service
  systemd:
    name: docker
    state: started
    enabled: yes
  tags:
    - docker
    - service

- name: Add users to docker group
  user:
    name: "{{ item }}"
    groups: docker
    append: yes
  loop: "{{ docker_users }}"
  tags:
    - docker
    - users
  notify: restart docker

- name: Install Docker Compose
  get_url:
    url: "https://github.com/docker/compose/releases/download/v{{ docker_compose_version }}/docker-compose-linux-x86_64"
    dest: /usr/local/bin/docker-compose
    mode: "0755"
  tags:
    - docker
    - docker-compose

- name: Create Docker Compose symlink
  file:
    src: /usr/local/bin/docker-compose
    dest: /usr/bin/docker-compose
    state: link
  tags:
    - docker
    - docker-compose

- name: Configure Docker daemon
  copy:
    content: |
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        },
        "storage-driver": "overlay2"
      }
    dest: /etc/docker/daemon.json
    mode: "0644"
  notify: restart docker
  tags:
    - docker
    - config

- name: Ensure Docker is running
  systemd:
    name: docker
    state: started
  tags:
    - docker
    - service

- name: Verify Docker installation
  command: docker --version
  register: docker_version_output
  changed_when: false
  tags:
    - docker
    - verify

- name: Verify Docker Compose installation
  command: docker-compose --version
  register: docker_compose_version_output
  changed_when: false
  tags:
    - docker
    - verify

- name: Display Docker version
  debug:
    msg:
      - "Docker: {{ docker_version_output.stdout }}"
      - "Docker Compose: {{ docker_compose_version_output.stdout }}"
  tags:
    - docker
    - verify

- name: Test Docker with hello-world
  docker_container:
    name: hello-world-test
    image: hello-world
    state: started
    auto_remove: yes
    detach: no
  tags:
    - docker
    - test
  ignore_errors: yes
```

roles/jenkins/tasks/main.yaml

```yaml
---
# Jenkins role - Install and configure Jenkins

- name: Import Jenkins GPG key
  rpm_key:
    key: "{{ jenkins_repo_key_url }}"
    state: present
  tags:
    - jenkins
    - repos

- name: Add Jenkins repository
  get_url:
    url: "{{ jenkins_repo_url }}"
    dest: /etc/yum.repos.d/jenkins.repo
    mode: "0644"
  tags:
    - jenkins
    - repos

- name: Install Jenkins
  yum:
    name: jenkins
    state: present
  tags:
    - jenkins
    - packages

- name: Ensure Jenkins home directory exists
  file:
    path: "{{ jenkins_home }}"
    state: directory
    owner: jenkins
    group: jenkins
    mode: "0755"
  tags:
    - jenkins
    - directories

- name: Configure Jenkins Java options
  lineinfile:
    path: /etc/sysconfig/jenkins
    regexp: "^JENKINS_JAVA_OPTIONS="
    line: 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Xmx2048m -Xms512m"'
    create: yes
  notify: restart jenkins
  tags:
    - jenkins
    - config

- name: Configure Jenkins port
  lineinfile:
    path: /etc/sysconfig/jenkins
    regexp: "^JENKINS_PORT="
    line: 'JENKINS_PORT="{{ jenkins_port }}"'
    create: yes
  notify: restart jenkins
  tags:
    - jenkins
    - config

- name: Start and enable Jenkins service
  systemd:
    name: jenkins
    state: started
    enabled: yes
  tags:
    - jenkins
    - service

- name: Wait for Jenkins to start
  wait_for:
    port: "{{ jenkins_port }}"
    delay: 10
    timeout: 300
  tags:
    - jenkins
    - service

- name: Wait for Jenkins to be ready (check initialAdminPassword)
  wait_for:
    path: "{{ jenkins_home }}/secrets/initialAdminPassword"
    timeout: 300
  tags:
    - jenkins
    - service

- name: Get Jenkins initial admin password
  slurp:
    src: "{{ jenkins_home }}/secrets/initialAdminPassword"
  register: jenkins_admin_password
  tags:
    - jenkins
    - password

- name: Display Jenkins initial admin password
  debug:
    msg: "Jenkins Initial Admin Password: {{ jenkins_admin_password.content | b64decode }}"
  tags:
    - jenkins
    - password

- name: Create Jenkins info file
  template:
    src: jenkins-info.j2
    dest: /home/ec2-user/jenkins-info.txt
    owner: ec2-user
    group: ec2-user
    mode: "0644"
  tags:
    - jenkins
    - info

- name: Install Jenkins CLI
  get_url:
    url: "http://localhost:{{ jenkins_port }}/jnlpJars/jenkins-cli.jar"
    dest: "{{ jenkins_home }}/jenkins-cli.jar"
    mode: "0644"
    owner: jenkins
    group: jenkins
  retries: 5
  delay: 10
  tags:
    - jenkins
    - cli

- name: Verify Jenkins is running
  uri:
    url: "http://localhost:{{ jenkins_port }}"
    status_code: 200,403
    timeout: 10
  register: jenkins_status
  retries: 5
  delay: 10
  tags:
    - jenkins
    - verify

- name: Display Jenkins status
  debug:
    msg: "Jenkins is running and accessible on port {{ jenkins_port }}"
  when: jenkins_status is succeeded
  tags:
    - jenkins
    - verify
```

### 6. Create Main Playbook

In the Playbooks directory create:
`jenkins-setup.yaml`

```yaml
---
# Main playbook for Jenkins server setup

- name: Configure Jenkins Server
  hosts: jenkins
  gather_facts: yes
  become: yes

  pre_tasks:
    - name: Display target hosts
      debug:
        msg: "Configuring {{ inventory_hostname }} ({{ ansible_host }})"
      tags: always

    - name: Wait for system to be ready
      wait_for_connection:
        delay: 5
        timeout: 300
      tags: always

    - name: Gather facts
      setup:
      tags: always

  roles:
    - role: common
      tags:
        - common
        - base

    - role: java
      tags:
        - java
        - jenkins-deps

    - role: git
      tags:
        - git
        - jenkins-deps

    - role: docker
      tags:
        - docker
        - jenkins-deps

    - role: jenkins
      tags:
        - jenkins

  post_tasks:
    - name: Display completion message
      debug:
        msg:
          - "=========================================="
          - "Jenkins Setup Complete!"
          - "=========================================="
          - "Jenkins URL: http://{{ ansible_host }}:{{ jenkins_port }}"
          - "SSH: ssh -i vockey.pem ec2-user@{{ ansible_host }}"
          - "Check /home/ec2-user/jenkins-info.txt for details"
          - "=========================================="
      tags: always

    - name: Create summary file
      copy:
        content: |
          Jenkins Configuration Summary
          =============================

          Configuration Date: {{ ansible_date_time.iso8601 }}
          Hostname: {{ ansible_hostname }}
          IP Address: {{ ansible_host }}

          Installed Components:
          - Java: {{ java_version }}
          - Docker: Installed
          - Git: Installed
          - Jenkins: {{ jenkins_version }}

          Services Status:
          - Docker: Active
          - Jenkins: Active on port {{ jenkins_port }}

          Next Steps:
          1. Access Jenkins at http://{{ ansible_host }}:{{ jenkins_port }}
          2. Use initial admin password from jenkins-info.txt
          3. Configure Jenkins plugins and settings

        dest: /home/ec2-user/ansible-summary.txt
        owner: ec2-user
        group: ec2-user
        mode: "0644"
      tags: always
```

### 7. Create Additional Playbooks

In the Playbooks Directory create:
verify.yaml

```yaml
---
# Verification playbook to check all installations

- name: Verify Jenkins Server Configuration
  hosts: jenkins
  gather_facts: yes
  become: yes

  tasks:
    - name: Check Java installation
      command: java -version
      register: java_check
      changed_when: false
      ignore_errors: yes

    - name: Check Git installation
      command: git --version
      register: git_check
      changed_when: false
      ignore_errors: yes

    - name: Check Docker installation
      command: docker --version
      register: docker_check
      changed_when: false
      ignore_errors: yes

    - name: Check Docker service status
      systemd:
        name: docker
      register: docker_service
      ignore_errors: yes

    - name: Check Jenkins installation
      command: systemctl status jenkins
      register: jenkins_check
      changed_when: false
      ignore_errors: yes

    - name: Check Jenkins service status
      systemd:
        name: jenkins
      register: jenkins_service
      ignore_errors: yes

    - name: Test Jenkins web interface
      uri:
        url: "http://localhost:8080"
        status_code: 200,403
      register: jenkins_web
      ignore_errors: yes

    - name: Check if initial admin password exists
      stat:
        path: /var/lib/jenkins/secrets/initialAdminPassword
      register: jenkins_password_file

    - name: Display verification results
      debug:
        msg:
          - "=========================================="
          - "Verification Results"
          - "=========================================="
          - "Java: {{ 'OK' if java_check.rc == 0 else 'FAILED' }}"
          - "Git: {{ 'OK' if git_check.rc == 0 else 'FAILED' }}"
          - "Docker: {{ 'OK' if docker_check.rc == 0 else 'FAILED' }}"
          - "Docker Service: {{ docker_service.status.ActiveState | default('UNKNOWN') }}"
          - "Jenkins: {{ 'OK' if jenkins_check.rc == 0 else 'FAILED' }}"
          - "Jenkins Service: {{ jenkins_service.status.ActiveState | default('UNKNOWN') }}"
          - "Jenkins Web: {{ 'OK' if jenkins_web.status == 200 or jenkins_web.status == 403 else 'FAILED' }}"
          - "Admin Password File: {{ 'EXISTS' if jenkins_password_file.stat.exists else 'NOT FOUND' }}"
          - "=========================================="

    - name: Get Jenkins initial password
      slurp:
        src: /var/lib/jenkins/secrets/initialAdminPassword
      register: jenkins_password
      when: jenkins_password_file.stat.exists

    - name: Display Jenkins password
      debug:
        msg: "Jenkins Initial Admin Password: {{ jenkins_password.content | b64decode }}"
      when: jenkins_password_file.stat.exists
```

maintenance.yaml

```yaml
---
# Maintenance playbook for Jenkins server

- name: Jenkins Server Maintenance
  hosts: jenkins
  gather_facts: yes
  become: yes

  tasks:
    - name: Update all packages
      yum:
        name: "*"
        state: latest
        update_cache: yes
      when: update_packages | default(false) | bool
      tags:
        - updates

    - name: Clean Docker system
      command: docker system prune -af --volumes
      when: clean_docker | default(false) | bool
      tags:
        - docker
        - cleanup

    - name: Restart Docker service
      systemd:
        name: docker
        state: restarted
      when: restart_docker | default(false) | bool
      tags:
        - docker
        - restart

    - name: Restart Jenkins service
      systemd:
        name: jenkins
        state: restarted
      when: restart_jenkins | default(false) | bool
      tags:
        - jenkins
        - restart

    - name: Check disk space
      shell: df -h
      register: disk_space
      changed_when: false
      tags:
        - info

    - name: Display disk space
      debug:
        var: disk_space.stdout_lines
      tags:
        - info

    - name: Check Jenkins logs
      command: journalctl -u jenkins -n 50 --no-pager
      register: jenkins_logs
      changed_when: false
      tags:
        - logs

    - name: Display Jenkins logs
      debug:
        var: jenkins_logs.stdout_lines
      tags:
        - logs
```

### 8. Create Requirements File

requirements.txt

```txt
ansible>=2.12.0
boto3>=1.26.0
botocore>=1.29.0
```

### 9. Create Helper Scripts

run-ansible.sh

```bash
#!/bin/bash
set -e

# Script to run Ansible playbooks

ANSIBLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ANSIBLE_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Ansible Playbook Runner${NC}"
echo -e "${GREEN}=====================================${NC}"

# Check if key file exists
if [ ! -f ../terraform/vockey.pem ]; then
    echo -e "${RED}ERROR: SSH key not found at ../terraform/vockey.pem${NC}"
    echo "Please ensure your vockey.pem file is in ~/.ssh/"
    exit 1
fi

# Ensure correct permissions on key
chmod 400 ../terraform/vockey.pem

# Test dynamic inventory
echo -e "${YELLOW}Testing dynamic inventory...${NC}"
ansible-inventory -i ./inventory/aws_ec2.yaml --list

# Ping all hosts
echo -e "${YELLOW}Testing connectivity to hosts...${NC}"
ansible all -m ping

# Run the playbook
echo -e "${YELLOW}Running Jenkins setup playbook...${NC}"
ansible-playbook playbooks/jenkins-setup.yaml "$@"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Playbook execution completed!${NC}"
echo -e "${GREEN}=====================================${NC}"
```

test-inventory.sh

```bash
#!/bin/bash
set -e

# Script to test Ansible dynamic inventory

echo "======================================"
echo "Testing Ansible Dynamic Inventory"
echo "======================================"

# Test inventory listing
echo ""
echo "1. Listing all hosts from dynamic inventory:"
ansible-inventory -i ./inventory/aws_ec2.yaml  --graph

echo ""
echo "2. Listing hosts in JSON format:"
ansible-inventory -i ./inventory/aws_ec2.yaml --list

echo ""
echo "3. Testing connectivity with ping module:"
ansible all -m ping

echo ""
echo "4. Getting host facts:"
ansible all  -m setup -a "filter=ansible_distribution*"

echo ""
echo "======================================"
echo "Inventory test completed!"
echo "======================================"
```

### 10. Install Dependencies

```bash
pip3 install -r requirements.txt

ansible --version
python3 -c "import boto3; print('boto3:', boto3.__version__)"
```

---

### 11. Test Dynamic Inventory

```bash
# Make scripts executable
chmod +x run-ansible.sh test-inventory.sh


ansible-inventory -i ./inventory/aws_ec2.yaml  --graph

# Test connectivity
ansible all  -m ping
```

---

### 12. Run Ansible Playbook

```bash
# Run the complete setup (using helper script)
./run-ansible.sh

# OR run manually
ansible-playbook playbooks/jenkins-setup.yaml

# Run with verbose output (for debugging)
ansible-playbook playbooks/jenkins-setup.yaml -vvv

# Dry run first (recommended)
ansible-playbook playbooks/jenkins-setup.yaml --check
```

---

## Step 15: Verify Installation

```bash
# Run verification playbook
ansible-playbook playbooks/verify.yaml

# SSH into Jenkins server to check
ssh -i ../terraform/vockey.pem ec2-user@<JENKINS_IP>

# On Jenkins server, check:
cat /home/ec2-user/jenkins-info.txt
cat /home/ec2-user/ansible-summary.txt
sudo systemctl status jenkins
sudo systemctl status docker
docker --version
java -version
git --version
```

---

## Step 16: Commit to Repository

```bash
# Navigate to project root
cd ~/CloudDevOpsProject

# Add all Ansible files
git add ansible/

# Ensure sensitive files are ignored
echo "*.retry" >> .gitignore
echo "ansible.log" >> .gitignore
echo "*.pem" >> .gitignore

# Commit
git commit -m "Add Ansible configuration with roles for Jenkins setup: common, java, git, docker, jenkins with dynamic inventory"

# Push
git push origin main
```

---

## ✅ Task 5 Deliverables Checklist:

- [x] **Ansible playbooks created** - jenkins-setup.yaml, verify.yaml, maintenance.yaml
- [x] **Ansible roles implemented** - common, java, git, docker, jenkins
- [x] **Dynamic inventory configured** - AWS EC2 plugin
- [x] **Required packages installed** - Git, Docker, Java
- [x] **Jenkins installed** - Via Ansible role
- [x] **All files committed** - ✅

---
