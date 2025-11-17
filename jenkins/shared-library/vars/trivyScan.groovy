#!/usr/bin/env groovy

def call(String imageName, String imageTag, String severity = 'CRITICAL,HIGH', int exitCode = 0) {
    echo "Scanning image with Trivy: ${imageName}:${imageTag}"
    
    try {
        sh """
            # Check if Trivy is installed
            if ! command -v trivy &> /dev/null; then
                echo "Installing Trivy..."
                sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.rpm || true
            fi
            
            # Scan the image
            trivy image \
                --severity ${severity} \
                --exit-code ${exitCode} \
                --no-progress \
                --format table \
                ${imageName}:${imageTag}
        """
        
        echo "Trivy scan completed for ${imageName}:${imageTag}"
        return true
        
    } catch (Exception e) {
        echo "Trivy scan failed or found vulnerabilities: ${e.message}"
        if (exitCode != 0) {
            throw e
        }
        return false
    }
}
