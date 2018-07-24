pipeline {
    agent any 
    stages {
	
        stage('Job1') {
            steps{
			buildJob1()
                 }
        }
        stage('Job2') {
            steps{
			buildJob2()
                }
            }
        }
}


def buildJob1() {

			def props = readJSON file: 'properties.json', text: ''
                build job: 'Applications/App1', parameters: [string(name: 'REGION', value: props['App1']['REGION']), string(name: 'AMI', value: props['App1']['AMI'])]

}

def buildJob2() {

			def props = readJSON file: 'properties.json', text: ''
                build job: 'Applications/App2', parameters: [string(name: 'REGION', value: props['App2']['REGION']), string(name: 'AMI', value: props['App2']['AMI'])]

}