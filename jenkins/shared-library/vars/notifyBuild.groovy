#!/usr/bin/env groovy

def call(String buildStatus = 'SUCCESS') {
    // Build status with color
    def colorCode = buildStatus == 'SUCCESS' ? '#36A64F' : '#FF0000'
    def emoji = buildStatus == 'SUCCESS' ? '✅' : '❌'
    
    echo "${emoji} Build ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    echo "Build URL: ${env.BUILD_URL}"
    
    // You can add Slack, Email, or other notification integrations here
    // Example for console output:
    echo """
    ============================================
    ${emoji} BUILD ${buildStatus}
    ============================================
    Job: ${env.JOB_NAME}
    Build Number: ${env.BUILD_NUMBER}
    Build URL: ${env.BUILD_URL}
    Duration: ${currentBuild.durationString}
    ============================================
    """
}
