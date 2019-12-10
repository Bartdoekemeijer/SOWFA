#!/usr/bin/python

import numpy as np
from subprocess import call

templateDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/RE2019/template_wps_1turb"
mainDestDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/RE2019/runs"

def replaceLineInSymbFile(filePath,strToReplace,string):
	call("cp -r -L " + filePath + " " + filePath + "_tmp" , shell=True) # Create copy (non-symbolic)
	call("rm -f " + filePath , shell=True) # Remove symbolically linked file 
	call("mv " + filePath + "_tmp " + filePath , shell=True) # Rename copy to true file
	
	# Replace <string> in file
	with open(filePath) as f:
		newText=f.read().replace(strToReplace, string)
	with open(filePath, "w") as f:
		f.write(newText)


# Setup cases and submit jobs
for yawAngle in [280,290,300]:#,280,290,300]:
    for pitchAngle in [0.0]:
        folderName = "wps_yaw"+str(yawAngle)
        jobName = "10MW"+folderName
        
        destinationFolder = mainDestDirectory+"/"+folderName
        call("cp --preserve=links -r -s " + templateDirectory + " " + destinationFolder, shell=True)

        replaceLineInSymbFile(destinationFolder+'/runscript.solve.1','<templ_job_name>', jobName) # job name
        replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<yawAngle>', str(yawAngle))
        replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<pitchAngle>', str(pitchAngle)) 

        call("cd " + destinationFolder + " && qsub runscript.solve.1", shell=True) # submit job to queue
