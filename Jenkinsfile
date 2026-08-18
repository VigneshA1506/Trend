pipeline {
    agent any
 
    stages {
 
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/VigneshA1506/Trend.git'
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
                        docker tag trend-app vickyamav/trend-app:latest
                        docker push vickyamav/trend-app:latest
                        docker logout
                    '''
                }
            }
        }
    }
}