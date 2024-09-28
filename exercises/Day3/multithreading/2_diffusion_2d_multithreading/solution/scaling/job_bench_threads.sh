#!/bin/bash
#SBATCH --job-name=diff2dthreads_bench
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=5gb
#SBATCH --partition=compute
#SBATCH --output=job_bench_threads.out
#SBATCH --exclusive
#SBATCH --account=research-eemcs-diam

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

for i in 6144 16384
do
    echo -e "\n\n#### Run $i"

    julia --project --threads 12 bench_threads.jl $i # benchmark multithreaded variants
done