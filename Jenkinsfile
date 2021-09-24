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
            stage('Build Docker Image') {
               steps {
                   script {
                       echo '=======================Build Docker Image Start==============='
                       sh "docker build -t 257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:latest . "
                       echo '=======================Build Docker Image End================='
                   }
               }
            }
            stage('Push Docker Image') {
               steps {
                   script {
                       echo '=======================Push Docker Image Start==============='
                       withCredentials([usernamePassword(credentialsId: 'aws-ecr', passwordVariable: 'ECR_TOKEN', usernameVariable: 'ECR_LOGIN')]) {
                            sh "docker login -u AWS -p $ECR_TOKEN 257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic"
                            sh "docker push 257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:latest"
                       }
                       echo '=======================Push Docker Image End================='
                   }
               }
            }
            // stage('Build Docker Image') {
            //     steps {
            //         script {
            //             echo '==================================Build Docker Image Start=================================='
            //             app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER}")
            //             echo '===================================Build Docker Image End==================================='
            //         }
            //     }
            // }
            // stage('Push Docker Image') {
            //     steps {
            //         script {
            //             echo '==================================Push Docker Image Start=================================='
            //             docker.withRegistry('https://257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic', 'aws1') {
            //                 // app.push("${env.BUILD_NUMBER}")
            //                 app.push("latest")
            //             }
            //             echo '===================================Push Docker Image End==================================='
            //         }
            //     }
            // }
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
