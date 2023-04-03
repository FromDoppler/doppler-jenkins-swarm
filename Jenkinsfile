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
        stage('Verify definition files') {
            steps {
                sh 'sh ./verify-all.sh'
            }
        }
    }
}
