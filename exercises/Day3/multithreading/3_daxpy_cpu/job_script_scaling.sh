#!/bin/bash
#SBATCH --job-name=daxpy_scaling
#SBATCH --time=00:20:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=150gb
#SBATCH --partition=compute
#SBATCH --output=job_script.out
#SBATCH --exclusive

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# run program
julia --project -t 48 daxpy_cpu_scaling.jl