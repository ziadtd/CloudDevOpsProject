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

[`ansible.cfg`](../ansible/ansible.cfg)

Then in the Inventroy dierctory create:

[`aws_ec2.yaml`](../ansible/inventory/aws_ec2.yaml)


### 4: Create Group Variables

In the group_vars Directory create:

[`all.yaml`](../ansible/group_vars/all.yaml)


### 5. Create Ansible Roles

In the Roles Directory create the following files:

1. In the Common subdirectory create 
[`tasks/main.yaml`](../ansible/roles/common/tasks/main.yaml)

2. In the Java subdirectory create 
[`tasks/main.yaml`](../ansible/roles/java/tasks/main.yaml)

3. In the Git subdirectory create 
[`tasks/main.yaml`](../ansible/roles/git/tasks/main.yaml)

4. In the Docker subdirectory create 
[`tasks/main.yaml`](../ansible/roles/docker/tasks/main.yaml)

4. In the Jenkins subdirectory create 
[`tasks/main.yaml`](../ansible/roles/jenkins/tasks/main.yaml)


### 6. Create Main Playbook

In the Playbooks directory create:
[`jenkins-setup.yaml`](../ansible/playbooks/jenkins-setup.yaml)


### 7. Create Verification Playbook

In the Playbooks directory create:
[`verify.yaml`](../ansible/playbooks/verify.yaml)


### 8. Create Requirements File

In the Root directory create:
[`requirements.txt`](../ansible/requirements.txt)


### 9. Create Helper Script

create te script to check hosts connection andrun the playbook:

[`run-ansible.sh`](../ansible/run-ansible.sh)


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

