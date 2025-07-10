pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'ap-south-1'
        EKS_CLUSTER_NAME = 'my-eks-cluster'
        
        // Application Configuration
        APP_NAME = 'sample-web-app'
        NAMESPACE = 'sample-apps'
        
        // Docker Registry - Using local Docker for simplicity
        IMAGE_NAME = "${APP_NAME}"
        IMAGE_TAG = "${BUILD_NUMBER}"
        
        // Since you're using IAM role, we don't need AWS credentials
        // AWS_CREDENTIALS = credentials('aws-credentials')
        // KUBECONFIG_CREDENTIAL = credentials('kubeconfig-file')
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🔄 Checking out source code..."
                    checkout scm
                }
            }
        }
        
        stage('Environment Setup') {
            steps {
                script {
                    echo "🔧 Setting up environment..."
                    
                    sh '''
                        # Verify tools are available
                        echo "Checking environment..."
                        whoami
                        pwd
                        
                        # Check kubectl
                        kubectl version --client
                        
                        # Check AWS CLI
                        aws sts get-caller-identity
                        
                        # Check Docker
                        docker --version
                    '''
                }
            }
        }
        
        stage('Configure EKS Access') {
            steps {
                script {
                    echo "☸️ Configuring EKS cluster access..."
                    
                    sh """
                        # Configure kubectl for EKS cluster
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        
                        # Verify cluster connection
                        kubectl cluster-info
                        kubectl get nodes
                    """
                }
            }
        }
        
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    echo "📝 Updating Kubernetes manifests..."
                    
                    // Add build info to ConfigMap
                    sh """
                        # Create build timestamp
                        BUILD_TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S')
                        
                        echo "Current directory: \$(pwd)"
                        echo "Listing files:"
                        ls -la
                        
                        # Check if k8s-apps directory exists
                        if [ -d "k8s-apps/sample-web-app" ]; then
                            echo "Found k8s-apps/sample-web-app directory"
                            ls -la k8s-apps/sample-web-app/
                            
                            # Update ConfigMap with build information
                            if [ -f k8s-apps/sample-web-app/configmap.yaml ]; then
                                echo "Updating ConfigMap with build #${BUILD_NUMBER}"
                                sed -i "s|Build: .*|Build: #${BUILD_NUMBER} - \$BUILD_TIMESTAMP|g" k8s-apps/sample-web-app/configmap.yaml
                                echo "ConfigMap updated successfully"
                                
                                # Show the updated content
                                echo "Updated ConfigMap content:"
                                grep -A5 -B5 "Build:" k8s-apps/sample-web-app/configmap.yaml || echo "Build line not found"
                            else
                                echo "ConfigMap file not found at k8s-apps/sample-web-app/configmap.yaml"
                            fi
                        else
                            echo "k8s-apps/sample-web-app directory not found"
                            echo "Available directories:"
                            find . -type d -name "*k8s*" -o -name "*app*" | head -10
                        fi
                    """
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    echo "🚀 Deploying to EKS cluster..."
                    
                    dir('k8s-apps/sample-web-app') {
                        sh """
                            # Create namespace if it doesn't exist
                            kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f configmap.yaml
                            kubectl apply -f deployment.yaml
                            kubectl apply -f service.yaml
                            
                            # Apply ingress if AWS Load Balancer Controller is available
                            if kubectl get crd ingressclasses.networking.k8s.io &> /dev/null; then
                                kubectl apply -f ingress.yaml
                            else
                                echo "⚠️  AWS Load Balancer Controller not found, skipping ingress creation"
                            fi
                        """
                    }
                }
            }
        }
        
        stage('Wait for Deployment') {
            steps {
                script {
                    echo "⏳ Waiting for deployment to be ready..."
                    
                    sh """
                        # Wait for deployment to be ready
                        kubectl wait --for=condition=available --timeout=300s deployment/${APP_NAME} -n ${NAMESPACE}
                        
                        # Check pod status
                        kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME}
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo "✅ Verifying deployment..."
                    
                    sh """
                        # Get deployment status
                        echo "=== Deployment Status ==="
                        kubectl get deployment ${APP_NAME} -n ${NAMESPACE}
                        
                        echo "=== Pods ==="
                        kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -o wide
                        
                        echo "=== Service ==="
                        kubectl get service ${APP_NAME}-service -n ${NAMESPACE}
                        
                        echo "=== Ingress ==="
                        kubectl get ingress -n ${NAMESPACE} || echo "No ingress found"
                    """
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "🎉 Deployment completed successfully!"
                
                // Get application URL if available
                sh """
                    echo "=== Application URLs ==="
                    
                    # Try to get ingress URL
                    INGRESS_URL=\$(kubectl get ingress -n ${NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
                    
                    if [ ! -z "\$INGRESS_URL" ]; then
                        echo "🌍 Application URL: http://\$INGRESS_URL"
                    else
                        echo "⏳ Load Balancer URL not ready yet"
                        echo "Check later with: kubectl get ingress -n ${NAMESPACE}"
                    fi
                    
                    # Service URL (internal)
                    echo "🔗 Internal Service: http://${APP_NAME}-service.${NAMESPACE}.svc.cluster.local"
                """
            }
        }
        
        failure {
            script {
                echo "❌ Deployment failed!"
                
                // Get debugging information
                sh """
                    echo "=== Debugging Information ==="
                    kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} || echo "No pods found"
                    kubectl describe deployment ${APP_NAME} -n ${NAMESPACE} || echo "No deployment found"
                    kubectl logs -l app=${APP_NAME} -n ${NAMESPACE} --tail=50 || echo "No logs available"
                """
            }
        }
    }
}
