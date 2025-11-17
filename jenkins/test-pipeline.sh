#!/bin/bash

# Script to manually trigger Jenkins pipeline

JENKINS_URL="http://98.91.195.87:8080"
JOB_NAME="flask-app-ci-pipeline"
JENKINS_USER="admin"
JENKINS_TOKEN="112d3979bee0511e045134bd32e74fe0b0"

echo "======================================"
echo "Triggering Jenkins Pipeline"
echo "======================================"
echo "Job: ${JOB_NAME}"
echo "Jenkins URL: ${JENKINS_URL}"
echo "======================================"

# Trigger the pipeline
curl -X POST \
  "${JENKINS_URL}/job/${JOB_NAME}/build" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}"

echo ""
echo "Pipeline triggered successfully!"
echo "Check status at: ${JENKINS_URL}/job/${JOB_NAME}"
echo "======================================"
