pipeline {
    agent {
        label 'ansible'
    }
    stages {
        stage ('Get chekout'){
            steps {
                ws('kibana-role') { // новая рабочая директория для нашей роли
                    git branch: 'main', credentialsId: '56d713a4-f66a-47e6-a4bd-7191559e1587', url: 'git@github.com:maxship/kibana-role.git'
                }
            }
        }
        stage ('Install requiments'){
            steps {
                ws('kibana-role') {
                    sh "pip3 install -r test-requirements.txt"
                }
            }
        }
        stage ('molecule test'){
            steps {
                ws('kibana-role') {
                    sh 'mkdir molecule/default/files'
                    sh 'molecule test'
                }
            }
        }
        stage('Cleanup'){
            steps{
                cleanWs()
            }
        }
    }
}