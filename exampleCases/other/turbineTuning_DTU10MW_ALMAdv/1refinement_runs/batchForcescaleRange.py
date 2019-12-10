#!/usr/bin/python

import numpy as np
from subprocess import call

templateDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/10MW_1refinement_runs/10MW_1refinement_template"
mainDestDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/10MW_1refinement_runs/runs"

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
for forcescale in [0.7, 0.8, 0.9]:
    for kfactor in [0.8, 1.0, 1.15, 1.3, 1.5]:
        for dt in [0.80]:
            folderName = "10MW_1refinement_dt"+str(dt)+"_"+"k"+str(kfactor)+"_F"+str(forcescale)
            jobName = folderName
            
            destinationFolder = mainDestDirectory+"/"+folderName
            call("cp --preserve=links -r -s " + templateDirectory + " " + destinationFolder, shell=True)

            replaceLineInSymbFile(destinationFolder+'/runscript.solve.1','<templ_job_name>', jobName) # job name
            replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<forcescale>', str(forcescale)) # forcescale
            replaceLineInSymbFile(destinationFolder+'/constant/turbineProperties/DTU10MWRef','<kfactor>', str(kfactor)) # k-factor			
            replaceLineInSymbFile(destinationFolder+'/system/controlDict.1','<dt>', str(dt)) # k-factor	

            call("cd " + destinationFolder + " && qsub runscript.solve.1", shell=True) # submit job to queue
