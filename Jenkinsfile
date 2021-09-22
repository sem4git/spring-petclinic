pipeline {
    agent any
    // ansiColor('xterm') {
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
            stage('Deploy Infrastructure by Terraform') {
                steps {
                    script {
                        echo '============================Deploy Infrastructure by Terraform Start============================'
                        withCredentials([usernamePassword(credentialsId: 'aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                            sh """
                                # terraform remote config -backend=S3 -backend-config="bucket=david-jenkins-state" -backend-config="key=state.tfstate" -backend-config="region=eu-west-1" 
                                terraform -chdir=./terraform plan 
                            """
                        }
                        echo '============================Deploy Infrastructure by Terraform End==============================='
                    }
                }
            }
        }
    // }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    triggers {
        pollSCM('H/2 * * * *')
    }
}
properties([disableConcurrentBuilds()])
