# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi





# OpenFOAM-2.4.x
OpenFOAM-2.4.x()
{
   # Unset OpenFOAM environment variables.
   if [ -z "$FOAM_INST_DIR" ]; then
      echo "Nothing to unset..."
   else
      echo "Unsetting OpenFOAM environment variables..."
      . $FOAM_INST_DIR/OpenFOAM-$OPENFOAM_VERSION/etc/config/unset.sh
   fi

   # Unload any compilers already loaded
   echo "Purging modules..."
   module purge

   # Load the appropriate modules
   echo "Loading modules..."
   module load openfoam/2.4.0
   module load torque/4.2.10
   module load maui/3.3.1
   module list

   # Set the OpenFOAM version and installation directory
   export OPENFOAM_VERSION=2.4.0
   export OPENFOAM_NAME=OpenFOAM-$OPENFOAM_VERSION

   # Set the ZeroMQ compilation option to false
   echo "Disabling the compilation and usage of ZeroMQ."
   export COMPILEZEROMQ=0
}

# OpenFOAM-2.4.x_SSC
OpenFOAM-2.4.x_SSC()
{
   # Unset OpenFOAM environment variables.
   if [ -z "$FOAM_INST_DIR" ]; then
      echo "Nothing to unset..."
   else
      echo "Unsetting OpenFOAM environment variables..."
      . $FOAM_INST_DIR/OpenFOAM-$OPENFOAM_VERSION/etc/config/unset.sh
   fi

   # Unload any compilers already loaded
   module list   
   echo "Purging modules..."
   module purge

   # Load the appropriate modules
   echo "Loading modules..."
   module load openfoam/2.4.0
   module load torque/4.2.10
   module load maui/3.3.1
   module load matlab
   module list

   # Set the OpenFOAM version and installation directory
   export OPENFOAM_VERSION=2.4.0
   export OPENFOAM_NAME=OpenFOAM-$OPENFOAM_VERSION

   # Set the ZeroMQ compilation option to true
   echo "Enabling the compilation and usage of ZeroMQ."
   export COMPILEZEROMQ=1
   export ZEROMQ_HOME=$HOME/OpenFOAM/zeroMQ/libzmq/install
   export ZEROMQ_INCLUDE=$ZEROMQ_HOME/include
   export ZEROMQ_LIB=$ZEROMQ_HOME/lib64
   export LD_LIBRARY_PATH=$ZEROMQ_HOME/lib:$LD_LIBRARY_PATH
   export LD_LIBRARY_PATH=$ZEROMQ_HOME/lib64:$LD_LIBRARY_PATH   
   echo "Specified ZeroMQ directory: $ZEROMQ_HOME"   
}
