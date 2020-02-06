#!/bin/bash
#PBS -l nodes=1:ppn=20
#PBS -N "wps.10MW.ALMAdv.zmqSSC"

# User input
startTime=0                 # Start time
cores=20                    # Enter the number of cores you will preprocess on.
runNumber=1                 # Enter the run number (useful for keeping track of restarts).
solver=windPlantSolver.ALMAdvanced  # Enter the name of the flow solver.



cd $PBS_O_WORKDIR
echo "Starting OpenFOAM job at: " $(date)
echo "using " $cores " cores"

# Load the OpenFOAM module and MATLAB module on the cluster
echo "Loading the OpenFOAM and MATLAB modules..."
module load openfoam/2.4.0
module load matlab

# define the ZeroMQ paths
export ZEROMQ_INCLUDE=$HOME/OpenFOAM/zeroMQ/libzmq/install/include
export ZEROMQ_LIB=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64:$LD_LIBRARY_PATH

# Get the control dictionary for this particular run.
cp system/controlDict.$runNumber system/controlDict

# Find an available ZeroMQ port and save it to ssc/SSC.m and constant/turbineArrayProperties
python zmqPortScheduler.py > log.$runNumber.zmqPortScheduler 2>&1

# Run the solver and the MATLAB controller in parallel
(mpirun -np $cores $solver -parallel > log.$runNumber.$solver 2>&1) &
(cd ssc; matlab -nodisplay -noFigureWindows -logfile 'SSC_out.log' -r SSC)

echo "Ending OpenFOAM job at: " $(date)
