pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = '049429105451'
        AWS_DEFAULT_REGION = 'eu-north-1'
        IMAGE_REPO_NAME = 'flarum-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}://{IMAGE_REPO_NAME}"
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
                echo 'Configuring Composer limits and installing dependencies...'
                sh 'composer config --global process-timeout 1800'
                sh 'composer install --no-dev --optimize-autoloader --prefer-dist --ignore-platform-reqs'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building production Docker image...'
                script {
                    sh "docker build -t ${env.REPOSITORY_URI}:latest -t ${env.REPOSITORY_URI}:${env.IMAGE_TAG} ."
                }
            }
        }
        stage('Push to Amazon ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    echo 'Logging into Amazon ECR...'
                    script {
                        sh "aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${env.REPOSITORY_URI}"
                        echo 'Pushing Docker image to ECR...'
                        sh "docker push ${env.REPOSITORY_URI}:latest"
                        sh "docker push ${env.REPOSITORY_URI}:${env.IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Deploy to AWS ECS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    echo 'Forcing deployment update on AWS ECS Service...'
                    script {
                        sh "aws ecs update-service --cluster ${env.ECS_CLUSTER_NAME} --service ${env.ECS_SERVICE_NAME} --force-new-deployment --region ${env.AWS_DEFAULT_REGION}"
                    }
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
