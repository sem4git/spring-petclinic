pipeline {
    agent any

   
    stages {
        stage('Build') {
            steps {
                ansiColor('xterm') {
                    sh './mvnw package'
                
                }
            }
        }
        //stage('Build Docker Image') {
        //    steps {
        //        ansiColor('xterm') {
        //            echo '=======================Build Docker Image Start==============='
        //            sh "docker build -t 257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER} . "
        //            echo '=======================Build Docker Image End================='
        //        }
        //    }
        //}
        stage('Build Docker Image') {
            steps {
                script {
                    echo '==================================Build Docker Image Start=================================='
                    app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER}")
                    echo '===================================Build Docker Image End==================================='
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    echo '==================================Push Docker Image Start=================================='
                    docker.withRegistry('https://257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic', 'aws-ecr') {
                        app.push("${env.BUILD_NUMBER}")
                        //app.push("latest")
                    }
                    echo '===================================Push Docker Image End==================================='
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    echo '============================Deploy Infrastructure by Terraform Start============================'
                    // docker.withRegistry('https://257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic', 'aws-ecr') {
                    //     app.push("${env.BUILD_NUMBER}")
                    //     //app.push("latest")
                    // }
                    echo '============================Deploy Infrastructure by Terraform End==============================='
                }
            }
        }
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    triggers {
        pollSCM('H/2 * * * *')
    }
}
properties([disableConcurrentBuilds()])
