#!/usr/bin/python

import numpy as np
from subprocess import call

templateDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/20181127_detailedTuningALMAdv_10MW/10MW_3refinements_runs/10MW_3refinements_dt0.05_template"
mainDestDirectory = "/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/simulationCases/20181127_detailedTuningALMAdv_10MW/10MW_3refinements_runs/runs"

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
for forcescale in [1.15]:
    for kfactor in [0.8, 1.0, 1.15, 1.3, 1.5]:
        folderName = "10MW_3refinements_dt0.05_"+"k"+str(kfactor)+"_F"+str(forcescale)
        jobName = folderName
        
        destinationFolder = mainDestDirectory+"/"+folderName
        call("cp --preserve=links -r -s " + templateDirectory + " " + destinationFolder, shell=True)

        replaceLineInSymbFile(destinationFolder+'/runscript.solve.1','<templ_job_name>', jobName) # job name
        replaceLineInSymbFile(destinationFolder+'/constant/turbineArrayProperties','<forcescale>', str(forcescale)) # forcescale
        replaceLineInSymbFile(destinationFolder+'/constant/turbineProperties/DTU10MWRef','<kfactor>', str(kfactor)) # k-factor			

        call("cd " + destinationFolder + " && qsub runscript.solve.1", shell=True) # submit job to queue
