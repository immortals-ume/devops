// Jenkinsfile - Declarative Pipeline

pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }
    
    environment {
        REGISTRY = 'docker.io'
        IMAGE_NAME = 'myorg/myapp'
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        KUBECONFIG_DEV = credentials('kubeconfig-dev')
        KUBECONFIG_PROD = credentials('kubeconfig-prod')
        SONAR_TOKEN = credentials('sonar-token')
        HELM_VERSION = '3.13.0'
        KUBECTL_VERSION = '1.28.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Validate') {
            parallel {
                stage('Validate YAML') {
                    steps {
                        sh '''
                            yamllint -c .yamllint local/kubernetes/ local/helm-charts/ local/helmfile/ || true
                        '''
                    }
                }
                
                stage('Validate Helm Charts') {
                    steps {
                        sh '''
                            cd local/helm-charts
                            for chart in */; do
                                helm lint "$chart"
                            done
                        '''
                    }
                }
                
                stage('Validate Kubernetes') {
                    steps {
                        sh '''
                            kubectl apply --dry-run=client -f local/kubernetes/db/
                            kubectl apply --dry-run=client -f local/kubernetes/cache/
                        '''
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh '''
                            npm ci
                            npm run test
                            npm run test:coverage
                        '''
                    }
                    post {
                        always {
                            junit 'test-results/**/*.xml'
                            publishHTML([
                                reportDir: 'coverage',
                                reportFiles: 'index.html',
                                reportName: 'Coverage Report'
                            ])
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh '''
                            docker-compose -f docker-compose.test.yml up -d
                            npm run test:integration
                            docker-compose -f docker-compose.test.yml down
                        '''
                    }
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('Trivy Scan') {
                    steps {
                        sh '''
                            trivy fs --exit-code 0 --no-progress .
                            trivy fs --exit-code 1 --severity CRITICAL --no-progress .
                        '''
                    }
                }
                
                stage('NPM Audit') {
                    steps {
                        sh 'npm audit --audit-level=moderate || true'
                    }
                }
                
                stage('SonarQube') {
                    when {
                        branch 'main'
                    }
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            sh '''
                                sonar-scanner \
                                    -Dsonar.projectKey=${JOB_NAME} \
                                    -Dsonar.sources=. \
                                    -Dsonar.host.url=${SONAR_HOST_URL} \
                                    -Dsonar.login=${SONAR_TOKEN}
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'docker-hub-credentials') {
                        def customImage = docker.build("${IMAGE_NAME}:${GIT_COMMIT_SHORT}")
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
        
        stage('Package Helm Charts') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    cd local/helm-charts
                    mkdir -p packages
                    for chart in */; do
                        helm package "$chart" -d packages/
                    done
                '''
                archiveArtifacts artifacts: 'local/helm-charts/packages/*.tgz', fingerprint: true
            }
        }
        
        stage('Deploy to Development') {
            when {
                branch 'develop'
            }
            steps {
                input message: 'Deploy to Development?', ok: 'Deploy'
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-dev']) {
                        sh '''
                            cd local/helmfile
                            local/helmfile -e dev diff
                            local/helmfile -e dev apply
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Staging?', ok: 'Deploy'
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-staging']) {
                        sh '''
                            cd local/helmfile
                            local/helmfile -e uat diff
                            local/helmfile -e uat apply
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy', submitter: 'admin'
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-prod']) {
                        sh '''
                            cd local/helmfile
                            local/helmfile -e production diff
                            local/helmfile -e production apply --wait
                        '''
                    }
                }
            }
        }
        
        stage('Smoke Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                sh '''
                    kubectl run smoke-test --image=curlimages/curl:latest --rm -i --restart=Never -- \
                        curl -f http://myapp.myapp.svc.cluster.local/health || exit 1
                '''
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            // Send notification
        }
        failure {
            echo 'Pipeline failed!'
            // Send notification
        }
    }
}
