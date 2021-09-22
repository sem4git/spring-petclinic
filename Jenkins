pipeline {
    agent any

   
    stages {
        stage('Checkout') {
            steps {
                ansiColor('xterm') {
                    git branch: 'main', credentialsId: 'github', url: 'https://github.com/sem4git/spring-petclinic.git'
                }
            }
        }
        stage('Build') {
            steps {
                ansiColor('xterm') {
                    sh './mvnw package'
                
                }
            }

            //post {
            //    // If Maven was able to run the tests, even if some of the test
             //   // failed, record the test results and archive the jar file.
              //  success {
            //        junit '**/target/surefire-reports/TEST-*.xml'
             //       archiveArtifacts 'target/*.jar'
              //  }
            //}
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
                    app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER}")
                    //app = docker.build("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:333")
                    //app.inside {
                    //    sh 'echo $(curl localhost:8080)'
                    //}
                }
            }
        }
        stage('Push Docker Image') {
            //when {
            //    branch 'master'
            //}
            steps {
                script {
                    docker.withRegistry('https://257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic', 'aws-ecr') {
                        app.push("${env.BUILD_NUMBER}")
                        //app.push("latest")
                    }
                }
            }
        }
        //stage('Push Docker Image') {
        //    steps {
        //       docker.withRegistry("https://257356753023.ecr.eu-central-1.amazonws.com", "ecr:eu-central-1:aws") {
        //            docker.image("257356753023.dkr.ecr.eu-central-1.amazonaws.com/petclinic:${env.BUILD_NUMBER}").push()
        //        }
        //    }
        //}
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
