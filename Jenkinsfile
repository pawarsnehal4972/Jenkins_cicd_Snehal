// Jenkins declarative pipeline - Flask backend
// Job type: Pipeline > "Pipeline script from SCM" (this file lives in the repo root)
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // Fires on every GitHub push once the webhook is configured (needs the GitHub plugin).
    triggers {
        githubPush()
    }

    environment {
        APP_NAME  = 'flask-backend'
        APP_DIR   = '/home/ec2-user/apps/flask-backend'
        APP_PORT  = '5000'
        // Lets pm2 keep running after the build finishes (Jenkins would otherwise kill child processes).
        JENKINS_NODE_COOKIE = 'dontKillMe'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling the latest code from Git...'
                checkout scm
                sh 'git log -1 --pretty="Commit: %h - %s (%an)"'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    venv/bin/pip install --upgrade pip
                    venv/bin/pip install -r requirements.txt -r requirements-dev.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh 'venv/bin/pytest -v --junitxml=test-results.xml'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'test-results.xml'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Optional enhancement: inject a secret from Jenkins credentials (id: flask-api-key).
                    def hasKey = false
                    try {
                        withCredentials([string(credentialsId: 'flask-api-key', variable: 'PROBE')]) { hasKey = true }
                    } catch (err) {
                        echo "Credential 'flask-api-key' not found - deploying without API_KEY"
                    }

                    def deployCmd = '''
                        mkdir -p "$APP_DIR"
                        rsync -a --delete --exclude venv --exclude .git --exclude tests \
                              --exclude __pycache__ --exclude .pytest_cache ./ "$APP_DIR/"
                        cd "$APP_DIR"
                        python3 -m venv venv
                        venv/bin/pip install --no-cache-dir -r requirements.txt
                        pm2 startOrRestart ecosystem.config.js --update-env
                        pm2 save
                    '''
                    if (hasKey) {
                        withCredentials([string(credentialsId: 'flask-api-key', variable: 'API_KEY')]) {
                            sh deployCmd
                        }
                    } else {
                        sh deployCmd
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 5
                    curl --fail --silent --show-error http://localhost:${APP_PORT}/api/health
                    echo
                    pm2 list
                '''
            }
        }
    }

    post {
        success { echo "${APP_NAME} deployed successfully." }
        failure { echo "${APP_NAME} pipeline FAILED - check the stage logs above." }
        cleanup { cleanWs() }
    }
}
