pipeline {
    agent {
        label 'dev-tools'
    }
    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'branch to build. If other than master is passed, wont deploy on DEV environment')
    }

    environment {
        REPO = 'git@github.com:xpurto/mystro-backend-discovery.git'
        DOCKER_REGISTRY = 'europe-west1-docker.pkg.dev/dev-1-386121/mystroapp-docker'
        CREDENTIALS_ID = 'GitHubCredentials'
        SERVICE = 'mystro-backend-discovery'
        VERSION = ''
    }

    stages {
        stage('Git clone') {
            steps {
                checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name:  "${params.BRANCH}"]], extensions: [], userRemoteConfigs: [[credentialsId: "${CREDENTIALS_ID}", url: "${REPO}"]]]

                script {
                    VERSION = sh(
                script: "/opt/mystro-build-scripts/build-check-version.sh ${DOCKER_REGISTRY} ${SERVICE}",
                returnStdout: true
                ).trim()
                }
            }
        }

        stage('Build java') {
            steps {
                sh 'chmod +x ./gradlew'
                sh './gradlew clean build jacocoTestReport'
            }
        }
        stage('Sonar scan') {
            steps {
                    sh 'sonar-scanner'
            }
        }
        stage('Docker') {
            steps {
                sh "/opt/mystro-build-scripts/docker-registry-deploy-script.sh ${SERVICE} ${VERSION} ${DOCKER_REGISTRY}"
            }
        }
        stage('Git tag') {
            steps {
                sh "/opt/mystro-build-scripts/build-tag-script-ms.sh"
            }
        }
        stage('DEV Deploy') {
            when {
                beforeAgent true
                expression {
                    params.BRANCH == 'master'
                }
            }
            steps {
                build job: 'deploy-container', parameters: [string(name: 'SERVICE_NAME', value: "${SERVICE}"), string(name: 'DEPLOY_VERSION', value: "${VERSION}")]
            }
        }
    }
}