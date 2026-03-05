pipeline {
    agent any

    environment {
        IMAGE_NAME = "bank-app"
        DOCKER_REPO = "zorochan/bank-app"
        SONAR_HOME = tool "Sonar"
        BUILD_NUMBER = BUILD_NUMBER
    }

    stages {

        stage("Workspace Cleanup") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/Harish1685/Springboot-BankApp.git'
            }
        }

        stage("Build Application") {
            
            steps { 

                sh "mvn clean package -DskipTests"  
            }
        }

        stage("SonarQube Scan") {
            steps {
                withSonarQubeEnv("Sonar") {
                    sh "$SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=bankapp -Dsonar.projectKey=bankapp -Dsonar.java.binaries=target"
                }
            }
        }

        stage("Docker Build") {
            steps {
                sh "docker build -t $IMAGE_NAME ."
                sh "docker tag $IMAGE_NAME $DOCKER_REPO:$BUILD_NUMBER"
            }
        }

        stage("Trivy Scan") {
            steps {
                sh "trivy image $DOCKER_REPO:$BUILD_NUMBER"
            }
        }

        stage("Push Image") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhubID',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push zorochan/bank-app:$BUILD_NUMBER
                    '''
                }
            }
        }

        stage("Deploy") {
            steps {
                sh "docker compose down"
                sh "docker compose up -d"
            }
        }
    }
}