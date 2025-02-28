@Library('tfc-lib@adef-ci') _

flags = gitParseFlags()

dockerConfig = getDockerConfig(['MATLAB','Vivado','Internal'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2023b")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['master']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	withEnv(['HDLBRANCH='+branchName,'LC_ALL=C.UTF-8','LANG=C.UTF-8']) {
	    checkout scm
	    sh 'git submodule update --init' 
	    sh 'make -C ./CI/scripts gen_tlbx'
	}
        local_stash('builtSources')
        archiveArtifacts artifacts: '*.mltbx', followSymlinks: false, allowEmptyArchive: true
    }
}

/////////////////////////////////////////////////////

classNames = ['IMU']

stage("Hardware Streaming Tests") {
    dockerParallelBuild(classNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['HW='+branchName]) {
            local_unstash('builtSources')
            sh 'make -C ./CI/scripts test_streaming'
        }
    }
}

//////////////////////////////////////////////////////

node('docker') {
    cstage('Deploy Development', "", flags) {
        local_unstash('builtSources', '', false)
        uploadArtifactory('SensorToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        cstage('Deploy Production', "", flags) {
            local_unstash('builtSources', '', false)
            uploadFTP('SensorToolbox','*.mltbx')
        }
    }
}

