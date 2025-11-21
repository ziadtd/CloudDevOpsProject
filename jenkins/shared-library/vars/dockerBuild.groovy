#!/usr/bin/env groovy
def call(String imageName, String imageTag, String dockerfilePath = './docker') {
    echo "Building Docker image: ${imageName}:${imageTag}"
    
    try {
        script {
            docker.build("${imageName}:${imageTag}", "${dockerfilePath}")
            
            echo "Successfully built ${imageName}:${imageTag}"
            return true
        }
    } catch (Exception e) {
        echo "Failed to build Docker image: ${e.message}"
        throw e
    }
}
