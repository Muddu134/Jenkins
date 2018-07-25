import groovy.io.FileType
import groovy.json.JsonSlurperClassic

def create_pipeline(jobName) {
println jobName
//    def propertiesFile = new JsonSlurperClassic().parseText(readFileFromWorkspace('properties.json'))
    def propertiesFile = new JsonSlurperClassic().parseText(readFileFromWorkspace("Applications/" + jobName + '/properties.json'))

    pipelineJob('Applications/' + jobName) {
        parameters {
            propertiesFile.stringParam.each {

                stringParam(it.key,it.DefualtValue,"null")
            }
		
//            propertiesFile."${jobName}".each {
//            stringParam('REGION',it.REGION,"null")
//			stringParam('AMI',it.AMI,"null")
//            }
}


        definition {
            cps {                                                                                                     
                script(readFileFromWorkspace("Applications/" + jobName + '/Jenkinsfile'))
                sandbox()
            }
        }
    }
}

folder('Applications') {
}


String JobDir = "${WORKSPACE}" + "/Applications";

new File(JobDir).eachDir() { dir ->
    println "JobPath = " + dir.getPath()

    String jobName = dir.getPath().substring(dir.getPath().lastIndexOf("Applications/") + 13)
    println "JobName " + jobName
    create_pipeline(jobName)
}



    pipelineJob('Applications/Build_Infrastructure') {

        definition {
            cps {                                                                                                     
                script(readFileFromWorkspace('Build_Infrastructure/Jenkinsfile'))
                sandbox()
            }
        }
    }
	
	
	    pipelineJob('Skeleton_job_parallel') {


        definition {
            cps {                                                                                                     
                script(readFileFromWorkspace("ParallelJenkinsfile"))
                sandbox()
            }
        }
    }
	
	
//println jobName;
//create_pipeline(jobName, "Applications/" + jobName)  
//}

//new File(JobDir).eachFile() { file->  
//    jobName = file.getName()

//def list = []
//def dir = new File(workingDir)
//dir.eachFile (FileType.FILES) { file ->
//  list << file
//}


//list.each {
//String jobName = it.path.substring(it.path.lastIndexOf("Applications/") + 13)

//println jobName;
//
//}


