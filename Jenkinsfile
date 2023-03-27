pipeline {
    agent any
    stages {
        stage('Verify git commit conventions') {
            when {
                not {
                    branch 'INT'
                }
            }
            steps {
                sh 'sh ./gitlint.sh'
            }
        }
        stage('Verify Dockerfile lint') {
            steps {
                sh 'sh ./dockerlint.sh'
            }
        }
        stage('Verify .sh files') {
            steps {
                sh 'docker build --target verify-sh .'
            }
        }
        stage('Verify Format') {
            steps {
                sh 'docker build --target verify-format .'
            }
        }
        stage('Verify Compose files ') {
            steps {
                sh 'sh ./jenkins-stack/verify-jenkins-compose-files.sh'
            }
        }
        stage('Deploy to https://jenkins.fromdoppler.net/test/') {
            when {
                anyOf {
                    branch 'TEST'
                }
            }
            environment {
                SWARM_ENTRYPOINT = 'swarm.fromdoppler.net'
            }
            steps {
                sh 'echo "Publishing to the Jenkins server"'
                // TODO: it will be done in a different way, probably directly from the server

                sh '''
                ssh -p 2200 swarm-cd@${SWARM_ENTRYPOINT} \
                  "rm -rf /doppler-swarm/jenkins-stack"
                '''
                sh '''
                scp -P 2200 -r \
                  `pwd`/jenkins-stack swarm-cd@${SWARM_ENTRYPOINT}:/doppler-swarm/jenkins-stack
                '''
                sh '''
                ssh -p 2200 swarm-cd@${SWARM_ENTRYPOINT} \
                  "sh /doppler-swarm/jenkins-stack/deploy-jenkins-stack.sh -e=test"
                '''
            }
        }
        stage('Deploy to https://jenkins.fromdoppler.net/ci/') {
            when {
                anyOf {
                    branch 'main'
                }
            }
            environment {
                SWARM_ENTRYPOINT = 'swarm.fromdoppler.net'
            }
            steps {
                sh 'echo "Publishing to the Jenkins server"'
                // TODO: it will be done in a different way, probably directly from the server

                sh '''
                ssh -p 2200 swarm-cd@${SWARM_ENTRYPOINT} \
                  "rm -rf /doppler-swarm/jenkins-stack"
                '''
                sh '''
                scp -P 2200 -r \
                  `pwd`/jenkins-stack swarm-cd@${SWARM_ENTRYPOINT}:/doppler-swarm/jenkins-stack
                '''
                sh '''
                ssh -p 2200 swarm-cd@${SWARM_ENTRYPOINT} \
                  "sh /doppler-swarm/jenkins-stack/deploy-jenkins-stack.sh -e=prod"
                '''
            }
        }
    }
}
