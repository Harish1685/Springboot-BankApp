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
                sh "trivy image --timeout 15m $DOCKER_REPO:$BUILD_NUMBER"
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

        stage("Update argoCD manifests"){
            steps{
                
                withCredentials([gitUsernamePassword(
                    credentialsId: "githubID", 
                    usernameVariable: "GIT_USER",
                    passwordVariable: "GIT_PASS")]) {
                        
                    sh '''
                    # clone maifests repo 
                    
                    git clone https://$GIT_USER:$GIT_PASS@github.com/Harish1685/Springboot-BankApp-GitOps.git
                    cd Springboot-BankApp/kubernetes/base
                    
                    # Update deployment image tag
                    
                    sed -i "s|image: zorochan/bank-app:.*|image: $DOCKER_REPO:$BUILD_NUMBER|" bankapp-deployment.yml
                    
                    # Commit & push changes
                    
                    git config user.name "Harish1685"
                    git config user.email "kumarharish1680@gmail.com"
                    git add .
                    git commit -m "Update bank-app image to $BUILD_NUMBER"
                    git push -u origin main
                    
                    '''
                     
                    }
                
            }
    }
}