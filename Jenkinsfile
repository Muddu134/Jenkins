pipeline {
    agent any 
    stages {
        stage('Job1') {
            steps{
                build job: 'Applications/App1', parameters: [string(name: 'REGION', value: 'ap-northeast-2'), string(name: 'AMI', value: 'AMI-46437')]
                 }
        }
        stage('Job2') {
            steps{
                build job: 'Applications/App2', parameters: [string(name: 'REGION', value: 'ap-northeast-1'), string(name: 'AMI', value: 'AMI-87337')]

                }
            }
        }
}
