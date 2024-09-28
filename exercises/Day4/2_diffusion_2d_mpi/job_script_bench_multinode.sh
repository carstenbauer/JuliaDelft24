#!/bin/bash
#SBATCH --job-name=diff2dmpi_bench_multinode
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1gb
#SBATCH --partition=compute
#SBATCH --output=job_script_bench_multinode.out
#SBATCH --exclusive

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# run MPI code
for i in 1 2 4 8
do
    echo -e "\n\n#### Run nranks=$i"
    mpiexecjl -n $i --map-by ppr:1:numa --bind-to core --report-bindings julia --project diffusion_2d_mpi.jl 1024 nosave
done
