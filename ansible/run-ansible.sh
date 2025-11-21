#!/bin/bash
set -e

# Script to run Ansible playbooks

ANSIBLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ANSIBLE_DIR"

# Check if key file exists
if [ ! -f ../terraform/vockey.pem  ]; then
    echo -e "ERROR: SSH key not found at ../terraform/vockey.pem$"
    echo "Please ensure your vockey.pem file is in ../terraform/"
    exit 1
fi

# Ensure correct permissions on key
chmod 400 ../terraform/vockey.pem

# Test dynamic inventory
echo -e "Testing dynamic inventory..."
ansible-inventory -i ./inventory/aws_ec2.yaml  --list

# Ping all hosts
echo -e "Testing connectivity to hosts..."
ansible all -m ping

# Run the playbook
echo -e "Running Jenkins setup playbook..."
ansible-playbook playbooks/jenkins-setup.yaml "$@"
