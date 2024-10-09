#!/bin/bash
#SBATCH --job-name=diff2dmpi_bench
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1gb
#SBATCH --partition=compute
#SBATCH --output=job_script_bench.out
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

# run MPI code
for i in 1 2 4 8 9 12 16
do
    echo -e "\n\n#### Run nranks=$i"
    mpiexecjl -n $i --map-by numa --bind-to core --report-bindings julia --project diffusion_2d_mpi.jl 1024 nosave
done
