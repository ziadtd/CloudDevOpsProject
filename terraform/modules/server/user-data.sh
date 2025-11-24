#!/bin/bash
set -e
yum update -y
amazon-linux-extras install java-openjdk11 -y

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y
systemctl start jenkins
systemctl enable jenkins

yum install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker jenkins
usermod -aG docker ec2-user

yum install git -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name":"${log_group_name}",
            "log_stream_name": "{instance_id}/jenkins.log"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "Jenkins/EC2",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MemoryUsedPercent",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DiskUsedPercent",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  }
}
CWCONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

sleep 30
JENKINS_PASS=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Not yet available")

cat > /home/ec2-user/jenkins-info.txt <<INFO
Jenkins Installation Complete!
==============================
Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080
Initial Admin Password: $JENKINS_PASS

To retrieve password later:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
INFO

echo "Jenkins installation completed successfully!"
