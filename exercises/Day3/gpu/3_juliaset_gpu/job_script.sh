#!/bin/bash
#SBATCH --job-name=juliaset_gpu
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-task=1
#SBATCH --mem=8gb
#SBATCH --partition=gpu-v100
#SBATCH --output=job_script.out

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# run program
julia --project juliaset_gpu.jl