#!/usr/bin/env groovy
def call(String manifestPath, String imageName, String imageTag) {
    echo "Updating Kubernetes manifests in ${manifestPath}"
    
    try {
        sh """
            # Update deployment.yaml with new image tag
            sed -i 's|image: .*${imageName}:.*|image: ${imageName}:${imageTag}|g' ${manifestPath}/deployment.yaml
            
            # Display changes
            echo "Updated manifest content:"
            grep "image:" ${manifestPath}/deployment.yaml
        """
        
        echo "Successfully updated manifests with ${imageName}:${imageTag}"
        return true
        
    } catch (Exception e) {
        echo "Failed to update manifests: ${e.message}"
        throw e
    }
}
