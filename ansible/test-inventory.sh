#!/bin/bash
set -e

echo "1. Listing all hosts from dynamic inventory:"
ansible-inventory -i ./inventory/aws_ec2.yaml --graph

echo ""
echo "2. Listing hosts in JSON format:"
ansible-inventory -i ./inventory/aws_ec2.yaml --list

echo "3. Testing connectivity with ping module:"
ansible all -m ping

echo "4. Getting host facts:"
ansible all  -m setup -a "filter=ansible_distribution*"
