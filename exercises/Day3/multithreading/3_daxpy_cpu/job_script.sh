#!/bin/bash
#SBATCH --job-name=daxpy_cpu
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=100gb
#SBATCH --partition=compute
#SBATCH --output=job_script.out
#SBATCH --exclusive
#SBATCH --account=education-eemcs-courses-julia 
#SBATCH --qos=reservation 
#SBATCH --reservation=JuliaWorkshopCPU

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# run program
julia --project -t 12 daxpy_cpu.jl
