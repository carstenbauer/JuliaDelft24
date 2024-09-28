#!/bin/bash
#SBATCH --job-name=cache_bandwidths
#SBATCH --output=job_script.out
#SBATCH --time=00:15:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=5gb
#SBATCH --partition=compute

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# run program
julia --project cache_bandwidths_solution.jl
julia --project cache_bandwidths_strided_solution.jl