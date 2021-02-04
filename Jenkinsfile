@Library('tfc-lib') _

dockerConfig = getDockerConfig(['MATLAB','Vivado'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2020a")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['master']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	withEnv(['HDLBRANCH='+branchName]) {
	    checkout scm
	    sh 'git submodule update --init' 
	    sh 'make -C ./CI/scripts gen_tlbx'
	}
        stash includes: '**', name: 'builtSources', useDefaultExcludes: false
        archiveArtifacts artifacts: '*.mltbx', followSymlinks: false, allowEmptyArchive: true
    }
}

/////////////////////////////////////////////////////

classNames = ['IMU']

stage("Hardware Streaming Tests") {
    dockerParallelBuild(classNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['HW='+branchName]) {
            unstash "builtSources"
            sh 'make -C ./CI/scripts test_streaming'
        }
    }
}

//////////////////////////////////////////////////////

node {
    stage('Deploy Development') {
        unstash "builtSources"
        uploadArtifactory('SensorToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        stage('Deploy Production') {
            unstash "builtSources"
            uploadFTP('SensorToolbox','*.mltbx')
        }
    }
}

