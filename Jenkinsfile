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
                sh 'echo run verify jenkins compose files...'
            }
        }
        stage('Deploy') {
            when {
                anyOf {
                    branch 'TEST'
                    branch 'main'
                }
            }
            environment {
                SWARM_ENTRYPOINT = 'swarm.fromdoppler.net'
            }
            steps {
                sh 'echo "Publishing to the Jenkins server'
                // TODO: it will be done in a different way, probably directly from the server
            }
        }
    }
}
