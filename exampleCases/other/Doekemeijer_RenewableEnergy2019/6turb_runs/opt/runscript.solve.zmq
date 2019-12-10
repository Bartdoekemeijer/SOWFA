#!/bin/bash
#PBS -N RE19.mixedOLCL
##PBS -l nodes=4:ppn=20
#PBS -l nodes=n06-62:ppn=20+n06-63:ppn=20+n06-64:ppn=20+n06-65:ppn=20
#PBS -q guest

cd $PBS_O_WORKDIR

# User Input.
startTime=20000             # Start time
cores=80                    # Enter the number of cores you will preprocess on.
runNumber=1                 # Enter the run number (useful for keeping track of restarts).
solver=windPlantSolver.ALMAdvanced  # Enter the name of the flow solver.


echo "Starting OpenFOAM job at: " $(date)
echo "using " $cores " cores"


# Source the bash profile and then call the appropriate OpenFOAM version function
# so that all the modules and environment variables get set.
echo "Sourcing the bash profile, loading modules, and setting the OpenFOAM environment variables..."
module load openfoam/2.4.0
module load matlab
export ZEROMQ_INCLUDE=$HOME/OpenFOAM/zeroMQ/libzmq/install/include
export ZEROMQ_LIB=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64:$LD_LIBRARY_PATH

# Add different SOWFA directory
export PATH=/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/platforms.bart/linux64GccDPOpt/bin:$PATH
export LD_LIBRARY_PATH=/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/platforms.bart/linux64GccDPOpt/lib:$LD_LIBRARY_PATH
export FOAM_USER_APPBIN=/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/platforms.bart/linux64GccDPOpt/bin
export FOAM_USER_LIBBIN=/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/platforms.bart/linux64GccDPOpt/lib

# Get the control dictionary for this particular run.
cp system/controlDict.$runNumber system/controlDict


# Run the solver.
(mpirun -np $cores $solver -parallel > log.$runNumber.$solver 2>&1) & 
(cd ssc; matlab -nodisplay -noFigureWindows -logfile 'SSC_out.log' -r SSC)

echo "Ending OpenFOAM job at: " $(date)
