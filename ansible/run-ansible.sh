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
if [ ! -f ../terraform/vockey.pem  ]; then
    echo -e "${RED}ERROR: SSH key not found at ../terraform/vockey.pem${NC}"
    echo "Please ensure your vockey.pem file is in ../terraform/"
    exit 1
fi

# Ensure correct permissions on key
chmod 400 ../terraform/vockey.pem

# Test dynamic inventory
echo -e "${YELLOW}Testing dynamic inventory...${NC}"
ansible-inventory -i ./inventory/aws_ec2.yaml  --list

# Ping all hosts
echo -e "${YELLOW}Testing connectivity to hosts...${NC}"
ansible all -m ping

# Run the playbook
echo -e "${YELLOW}Running Jenkins setup playbook...${NC}"
ansible-playbook playbooks/jenkins-setup.yaml "$@"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Playbook execution completed!${NC}"
echo -e "${GREEN}=====================================${NC}"
