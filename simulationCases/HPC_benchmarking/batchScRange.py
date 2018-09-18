#!/usr/bin/python

import numpy as np
from subprocess import call

templateDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/HPC_benchmarking/hpc_benchmark_template"
mainDestDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/HPC_benchmarking"
		

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
for pitch in [-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0]:
	for yaw in [270.0]:#range(240,310,10):
		folderName = "pitch"+str(pitch)+"yaw"+str(yaw)
		jobName    = "unifrm_pitch"+str(pitch)+"yaw"+str(yaw)
		destinationFolder = mainDestDirectory+"/"+folderName
		call("cp --preserve=links -r -s " + templateDirectory + " " + destinationFolder, shell=True)
		
		replaceLineInSymbFile(destinationFolder+'/runscript.solve.1','<templ_job_name>', jobName) # job name
		call("cd " + destinationFolder + " && qsub runscript.solve.1", shell=True) # submit job to queue
