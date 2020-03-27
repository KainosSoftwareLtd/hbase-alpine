pipeline {
    parameters {
        string(name: 'CONTAINER_REGISTRY', defaultValue: 'registry.internal-aws.ad:5000', description: 'The Docker container registry to pull and push images.')
        booleanParam(name: 'PUBLISH_BUILD_STATUS', defaultValue: true, description: 'Should the outcome of the build be published to the Teams channel?')
    }
    environment {
        MODULE_NAME = "build-hbase-alpine-ons-docker-image"
        SBT_OPTS = ''
    }
    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    agent any
    stages {
        stage('Checkout'){
            agent any
            steps{
                deleteDir()
                checkout scm
                stash name: 'Checkout'
            }
            post {
                failure {
                    script {
                        if (PUBLISH_BUILD_STATUS) {
                            office365ConnectorSend message: "Latest status of build #${currentBuild.number}", status:"Failed", color: 'FE1109', webhookUrl:'https://outlook.office.com/webhook/c0f4de6e-c5cc-4dcb-877b-413d791f9b64@7ed9bdc7-964d-4dc0-9084-812b90e05c6d/JenkinsCI/debd15fe369f4c6091e9b5df8364caf2/9721b3d1-bfe6-464a-ad69-239316f494ed'
                        }
                    }
                    postFail()
                }
            }
        }

        stage('Build and Push Docker Image') {
            agent any
            steps {
                unstash name: 'Checkout'
                sh """
                VERSION=\$(cat VERSION)
                docker build . -t ${params.CONTAINER_REGISTRY}/hbase-alpine-ons:latest
                docker tag ${params.CONTAINER_REGISTRY}/hbase-alpine-ons:latest ${params.CONTAINER_REGISTRY}/hbase-alpine-ons:\$VERSION
                docker push ${params.CONTAINER_REGISTRY}/hbase-alpine-ons:\$VERSION
                docker push ${params.CONTAINER_REGISTRY}/hbase-alpine-ons:latest
                """
            }
            post {
                success {
                    script {
                        if (PUBLISH_BUILD_STATUS) {
                            office365ConnectorSend message: "Latest status of build #${currentBuild.number}", status:"Success", color: '09FE27', webhookUrl:'https://outlook.office.com/webhook/c0f4de6e-c5cc-4dcb-877b-413d791f9b64@7ed9bdc7-964d-4dc0-9084-812b90e05c6d/JenkinsCI/debd15fe369f4c6091e9b5df8364caf2/9721b3d1-bfe6-464a-ad69-239316f494ed'
                        }
                    }
                    postSuccess()
                }
                failure {
                    script {
                        if (PUBLISH_BUILD_STATUS) {
                            office365ConnectorSend message: "Latest status of build #${currentBuild.number}", status:"Failed", color: 'FE1109', webhookUrl:'https://outlook.office.com/webhook/c0f4de6e-c5cc-4dcb-877b-413d791f9b64@7ed9bdc7-964d-4dc0-9084-812b90e05c6d/JenkinsCI/debd15fe369f4c6091e9b5df8364caf2/9721b3d1-bfe6-464a-ad69-239316f494ed'
                        }
                    }
                    postFail()
                }
            }
        }
    }
}

def postSuccess() {
    colourText('info', "Stage: ${env.STAGE_NAME} successfull!")
}

def postFail() {
    colourText('warn', "Stage: ${env.STAGE_NAME} failed!")
}

def colourText(level,text){
    wrap([$class: 'AnsiColorBuildWrapper']) {
        def code = getLevelCode(level)
        echo "${code[0]}${text}${code[1]}"
    }
}

def getLevelCode(level) {
    def colourCode
    switch (level) {
        case "info":
            // Blue
            colourCode = ['\u001B[34m','\u001B[0m']
            break
        case "error":
            // Red
            colourCode = ['\u001B[31m','\u001B[0m']
            break
        default:
            colourCode = ['\u001B[31m','\u001B[0m']
            break
    }
    colourCode
}
