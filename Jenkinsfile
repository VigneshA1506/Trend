pipeline {
    agent any
 
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
 
    stages {
 
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/VigneshA1506/Trend.git'
            }
        }
 
        stage('Docker Build') {
            steps {
                sh 'docker build -t trend-app .'
            }
        }
 
        stage('DockerHub Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker tag trend-app "$DOCKER_USERNAME/trend-app:latest"
                        docker push "$DOCKER_USERNAME/trend-app:latest"
                        docker logout
                    '''
                }
            }
        }
 
        stage('Kubernetes Deploy') {
            steps {
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
 
                    kubectl rollout status deployment/trend-app --timeout=180s
 
                    kubectl get pods
                    kubectl get svc
                '''
            }
        }
    }
}