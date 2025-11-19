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

### 4. Create Shared Library Structure

```bash
# Create shared library structure
mkdir -p jenkins/shared-library/vars
mkdir -p jenkins/shared-library/src
mkdir -p jenkins/shared-library/resources
```


### 5. Create Shared Library Functions

In the vars subdirectory create:

[`dockerBuild.groovy`](../jenkins/shared-library/vars/dockerBuild.groovy)

[`trivyScan.groovy`](../jenkins/shared-library/vars/trivyScan.groovy)

[`dockerPush.groovy`](../jenkins/shared-library/vars/dockerPush.groovy)

[`dockerCleanup.groovy`](../jenkins/shared-library/vars/dockerCleanup.groovy)

[`updateManifests.groovy`](../jenkins/shared-library/vars/updateManifests.groovy)

[`gitPushChages.groovy`](../jenkins/shared-library/vars/gitPushChages.groovy)


### 6. Create Main Jenkinsfile

In the Jenkins Directory create:

[`Jenkinsfile`](../jenkins/Jenkinsfile)

#### Note: To avoid Infinite loop an initial step is added to the Jenkins pipeline to ignore Commits pushed by Jenkins itself

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

In the repo create [`pipeline.yaml`](../.github/workflows/pipeline.yaml)


Then to trigger the Pipeline **Push a tag**:
   ```bash
   git tag v6.5
   git push origin v6.5
   ```

## Deliverables 
Github Pipeline File: at: `https://github.com/ziadtd/CloudDevOpsProject/blob/main/.github/workflows/pipeline.yaml`