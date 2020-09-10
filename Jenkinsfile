pipeline {
    agent any
    stages {
        stage('Linting...') {
            steps {
                sh 'make lint'
            }
        }
        stage('Building Docker container...') {
            steps {
                sh 'make docker-build'
            }
        }
        stage('Pushing Docker container...') {
            steps {
                withDockerRegistry([url: "", credentialsId: "docker-hub-credentials"]) {
                    sh 'make docker-push'
                }
            }
        }
    }
}
