#!/bin/bash
#SBATCH --job-name=diff2dthreads
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=10gb
#SBATCH --partition=compute
#SBATCH --output=job_script.out
#SBATCH --account=education-eemcs-courses-julia 
#SBATCH --qos=reservation 
#SBATCH --reservation=JuliaWorkshopCPU

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

for i in 64 128 512 1024
do
    echo -e "\n\n#### Run ns=$i"

    echo -e "-- single threaded"
    julia --project --threads 1 diffusion_2d_threads.jl $i
    echo -e ""

    echo -e "-- multithreaded (12 threads), dynamic scheduling"
    julia --project --threads 12 diffusion_2d_threads.jl $i
    echo -e ""

    echo -e "-- multithreaded (12 threads), static scheduling"
    julia --project --threads 12 diffusion_2d_threads.jl $i static
    echo -e ""
done