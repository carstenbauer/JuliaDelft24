#!/bin/bash
#SBATCH --job-name=diff2dmpigpu
#SBATCH --output=job_script.out
#SBATCH --time=00:05:00
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=10gb
#SBATCH --partition=gpu-v100

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job -> load the module(s)
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# enabling cuda support in mpi
export OMPI_MCA_mpi_cuda_support=1

# run MPI + CUDA code on 2 GPUs
mpiexecjl -n 2 --report-bindings julia --project diffusion_2d_mpi_gpu.jl
# combine the results and visualize them
julia --project visualize_mpi.jl

# run with higher resolution
# mpiexecjl -n 2 julia --project diffusion_2d_mpi_gpu.jl 16384 nosave
