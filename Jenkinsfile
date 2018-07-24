pipeline {
    agent any 
    stages {
	def props = readJson file: 'properties.json'
        stage('Job1') {
		
            steps{
			
                build job: 'Applications/App1', parameters: [string(name: 'REGION', value: "${props['App1']['REGION']}"), string(name: 'AMI', value: "${props['App1']['AMI']}")]
                 }
        }
        stage('Job2') {
            steps{
                build job: 'Applications/App2', parameters: [string(name: 'REGION', value: "${props['App2']['REGION']}"), string(name: 'AMI', value: "${props['App2']['AMI']}")]

                }
            }
        }
}
