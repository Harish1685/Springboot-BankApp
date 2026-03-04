pipeline {
    agent any

    stages {
        stage("checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/Harish1685/Springboot-BankApp.git'
            }
        }
        stage("testing"){
            steps{
                echo "some testing might be done"
            }
        }
        stage("building docker image"){
            steps{
                sh "docker build -t bank-app ."
            }
        }
        stage("pushing to dockerHub  and tagging "){
            steps{
              withCredentials([usernamePassword(
                  credentialsId: 'dockerhubID',
                  usernameVariable: 'DOCKER_USER',
                  passwordVariable: 'DOCKER_PASS'
                  )]) {
                    
                    sh  '''
                        echo "$DOCKER_PASS" | docker login -u $DOCKER_USER --password-stdin
                        docker image tag bank-app zorochan/bank-app:$BUILD_NUMBER
                        docker push zorochan/bank-app:$BUILD_NUMBER
                        '''
                        }  
            }
        }
        stage("deploy"){
            steps{
                sh "docker compose down"
                sh "docker compose up -d"
            }
        }
        }
}
