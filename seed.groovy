import groovy.io.FileType
import groovy.json.JsonSlurperClassic


def create_pipeline(jobName) {

    def allProjectDetails = new JsonSlurperClassic().parseText(readFileFromWorkspace("jobs/" + jobName + '/properties.json'))
    pipelineJob('project_jobs/' + jobName) {
        parameters {


            allProjectDetails.stringParam.each {

                stringParam(it.key,it.DefualtValue,"null")
            }

            allProjectDetails.choiceParam.each {


            choiceParam(it.key, it.choices)
        }
}


        definition {
            cps {                                                                                                     
                script(readFileFromWorkspace("jobs/" + jobName + '/Jenkinsfile'))
                sandbox()
            }
        }
    }
}

folder('project_jobs') {


}
String JobDir = "${WORKSPACE}" + "/jobs";

new File(JobDir).eachDir() { dir ->
    println "JobPath = " + dir.getPath()

    String jobName = dir.getPath().substring(dir.getPath().lastIndexOf("jobs/") + 5)
    println "JobName " + jobName
    create_pipeline(jobName)
}

//println jobName;
//create_pipeline(jobName, "jobs/" + jobName)  
//}

//new File(JobDir).eachFile() { file->  
//    jobName = file.getName()

//def list = []
//def dir = new File(workingDir)
//dir.eachFile (FileType.FILES) { file ->
//  list << file
//}


//list.each {
//String jobName = it.path.substring(it.path.lastIndexOf("jobs/") + 5)

//println jobName;
//
//}


