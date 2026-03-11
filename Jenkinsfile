pipeline {
    agent any

    environment {
        IMAGE_NAME = "bank-app"
        DOCKER_REPO = "zorochan/bank-app"
        SONAR_HOME = tool "Sonar"
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
                sh "docker build -t $DOCKER_REPO:$BUILD_NUMBER ."
            }
        }

        stage("Trivy Scan") {
            steps {
                sh "trivy image --timeout 15m $IMAGE_NAME"
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
                    docker tag $IMAGE_NAME $DOCKER_REPO:$BUILD_NUMBER
                    docker push $DOCKER_REPO:$BUILD_NUMBER

                    '''
                }
            }
        }

        stage("apply mannifest files and deploy to new version") {
            steps {
                 sh '''
                kubectl apply -f kubernetes/bankapp-namespace.yml

                sleep 5
                
                kubectl apply -f kubernetes/

                kubectl set image deployment/bank-app bank-app=$DOCKER_REPO:$BUILD_NUMBER -n bankapp-namespace 

                kubectl rollout status deployment/bank-app -n bankapp-namespace --timeout=300s

                kubectl wait --for=condition=ready pod -l app=bank-app -n bankapp-namespace --timeout=300s

                kubectl get pods -n bankapp-namespace
            '''
            }
        }
    }
}