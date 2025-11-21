#!/usr/bin/env groovy

def call(String buildStatus = 'SUCCESS') {   
    echo "Build ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    echo "Build URL: ${env.BUILD_URL}"
}
