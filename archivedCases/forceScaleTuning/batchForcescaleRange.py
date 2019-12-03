#!/usr/bin/python

import numpy as np
from subprocess import call

templateDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/forceScaleTuning/forceScaleTemplate_10x10x10"
mainDestDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/forceScaleRange/simulations_10x10x10"

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
for forcescale in [1.30]:
	for kfactor in [1.0, 1.15, 1.30]:
		for epsilon in [16.0, 21.0]:
			folderName = "F"+str(forcescale)+"_k"+str(kfactor)+"eps"+str(epsilon)
			jobName    = folderName
			destinationFolder = mainDestDirectory+"/"+folderName
			call("cp --preserve=links -r -s " + templateDirectory + " " + destinationFolder, shell=True)
			
			replaceLineInSymbFile(destinationFolder+'/runscript.solve.ADM','<templ_job_name>', jobName) # job name
			replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<forcescale>', str(forcescale)) # forcescale
			replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<epsilon>', str(epsilon)) # epsilon			
			replaceLineInSymbFile(destinationFolder+'/constant/turbineProperties/DTU10MWRef_ADM','<kfactor>', str(kfactor)) # k factor
		
			call("cd " + destinationFolder + " && qsub runscript.solve.ADM", shell=True) # submit job to queue
