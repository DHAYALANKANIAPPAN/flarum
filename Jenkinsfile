pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = '049429105451'
        AWS_DEFAULT_REGION = 'us-east-1'
        IMAGE_REPO_NAME = 'flarum-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        ECS_CLUSTER_NAME = 'flarum-production-cluster'
        ECS_SERVICE_NAME = 'flarum-web-service'
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Composer Install') {
            steps {
                echo 'Installing Composer Dependencies...'
                sh 'composer install --no-dev --prefer-dist --optimize-autoloader --ignore-platform-reqs'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building production Docker image...'
                sh "docker build -t \${REPOSITORY_URI}:latest -t \${REPOSITORY_URI}:\${IMAGE_TAG} ."
            }
        }
        stage('Push to Amazon ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    echo 'Logging into Amazon ECR...'
                    sh "aws ecr get-login-password --region \${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin \${REPOSITORY_URI}"
                    echo 'Pushing Docker image to ECR...'
                    sh "docker push \${REPOSITORY_URI}:latest"
                    sh "docker push \${REPOSITORY_URI}:\${IMAGE_TAG}"
                }
            }
        }
        stage('Deploy to AWS ECS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    echo 'Forcing deployment update on AWS ECS Service...'
                    sh "aws ecs update-service --cluster \${ECS_CLUSTER_NAME} --service \${ECS_SERVICE_NAME} --force-new-deployment --region \${AWS_DEFAULT_REGION}"
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment successful! Flarum cluster updated successfully.'
        }
        failure {
            echo 'Pipeline execution failed. Please verify console output logs.'
        }
    }
}
