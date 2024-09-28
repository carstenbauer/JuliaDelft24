#!/bin/bash

# Making module / ml available
# ------------------------------------------------------------
export MODULEPATH=/etc/scl/modulefiles:/etc/scl/modulefiles:/apps/noarch/modulefiles:/apps/generic/modulefiles
source /usr/share/lmod/lmod/init/profile
# ------------------------------------------------------------

# Load julia
module use /projects/julia/modulefiles
module load juliahpc
module load nvhpc # for MPI/CUDA

# Pass on all arguments to julia
exec julia "${@}"
