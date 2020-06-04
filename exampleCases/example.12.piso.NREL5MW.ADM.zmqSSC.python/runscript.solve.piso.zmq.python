#!/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -N "piso.5MW.ADM.zmqSSC.python"

# User input
startTime=0                 # Start time
cores=8                     # Enter the number of cores you will preprocess on.
runNumber=1                 # Enter the run number (useful for keeping track of restarts).
solver=pisoFoamTurbine.ADM  # Enter the name of the flow solver.



cd $PBS_O_WORKDIR
echo "Starting OpenFOAM job at: " $(date)
echo "using " $cores " cores"

# path to local python 3 install with ZMQ
export PATH=$HOME/anaconda3/bin:$PATH

# Load the OpenFOAM module on the cluster
echo "Loading the OpenFOAM and modules..."
module load openfoam/2.4.0

# define the ZeroMQ paths
export ZEROMQ_INCLUDE=$HOME/OpenFOAM/zeroMQ/libzmq/install/include
export ZEROMQ_LIB=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/OpenFOAM/zeroMQ/libzmq/install/lib64:$LD_LIBRARY_PATH

# Get the control dictionary for this particular run.
cp system/controlDict.$runNumber system/controlDict

# Find an available ZeroMQ port and save it to ssc/ssc.py and constant/turbineArrayProperties
python zmqPortScheduler.py > log.$runNumber.zmqPortScheduler 2>&1

# Run the solver and the MATLAB controller in parallel
(mpirun -np $cores $solver -parallel > log.$runNumber.$solver 2>&1) &
(cd ssc; python ssc.py)

echo "Ending OpenFOAM job at: " $(date)