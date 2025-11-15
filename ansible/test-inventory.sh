#!/bin/bash
set -e

# Script to test Ansible dynamic inventory

echo "======================================"
echo "Testing Ansible Dynamic Inventory"
echo "======================================"

# Test inventory listing
echo ""
echo "1. Listing all hosts from dynamic inventory:"
ansible-inventory  --graph

echo ""
echo "2. Listing hosts in JSON format:"
ansible-inventory --list

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

