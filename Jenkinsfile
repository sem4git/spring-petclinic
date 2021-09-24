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
                        echo '==================================Build Docker Image Start=================================='
                        // app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER}")
                        app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:latest")
                        echo '===================================Build Docker Image End==================================='
                    }
                }
            }
            stage('Push Docker Image') {
                steps {
                    script {
                        echo '==================================Push Docker Image Start=================================='
                        docker.withRegistry('https://257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic', 'ecr:eu-central-1:aws1') {
                            app.push("${env.BUILD_NUMBER}")
                            app.push("latest")
                            app.rmi("latest")
                        }
                        echo '===================================Push Docker Image End==================================='
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
