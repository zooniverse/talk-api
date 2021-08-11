#!groovy

pipeline {
  agent none

  options {
    quietPeriod(120)
    disableConcurrentBuilds()
  }

  stages {

    stage('Build Docker image') {
      agent any
      environment { 
        DOCKER_BUILDKIT = 1
      }
      steps {
        script {
          def dockerRepoName = 'zooniverse/talk-api'
          def dockerImageName = "${dockerRepoName}:${GIT_COMMIT}"
          def newImage = docker.build(dockerImageName)
          newImage.push()

          if (BRANCH_NAME == 'master') {
            stage('Update latest tag') {
              newImage.push('latest')
            }
          }
          if (env.TAG_NAME == 'production-release') {
            stage('Update production release tag') {
              newImage.push('production-release')
            }
          }
        }
      }
    }

    stage('Dry run deployments') {
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --dry-run=client --record -f -"
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl --context azure apply --dry-run=client --record -f -"
      }
    }

    stage('Deploy production to Kubernetes') {
      when { tag 'production-release' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-production.tmpl | kubectl --context azure apply --record -f -"
      }
      post {
        success {
          script {
            if (env.TAG_NAME == 'production-release') {
              slackSend (
                color: '#00FF00',
                message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
                channel: "#ops"
              )
            }
          }
        }

        failure {
          script {
            if (env.TAG_NAME == 'production-release') {
              slackSend (
                color: '#FF0000',
                message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
                channel: "#ops"
              )
            }
          }
        }
      }
    }

    stage('Deploy staging to Kubernetes') {
      when { branch 'master' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment-staging.tmpl | kubectl --context azure apply --record -f -"
      }
      post {
        success {
          script {
            if (env.BRANCH_NAME == 'master') {
              slackSend (
                color: '#00FF00',
                message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
                channel: "#ops"
              )
            }
          }
        }

        failure {
          script {
            if (env.BRANCH_NAME == 'master') {
              slackSend (
                color: '#FF0000',
                message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
                channel: "#ops"
              )
            }
          }
        }
      }
    }
  }
}
