#!/bin/bash
#SBATCH --job-name=diff2dmpigpu
#SBATCH --output=job_script_A100.out
#SBATCH --time=00:05:00
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=10gb
#SBATCH --partition=gpu-a100
#SBATCH --account=research-eemcs-diam

if [[ -n "${SLURM_JOBID}" ]]; then
    # we're running as a cluster job → load modules
    module use /projects/julia/modulefiles
    module load juliahpc
    module load nvhpc
fi

# enabling cuda support in mpi
export OMPI_MCA_mpi_cuda_support=1

# run MPI + CUDA code on 4 GPUs
mpiexecjl -n 4 --report-bindings julia --project diffusion_2d_mpi_gpu.jl
# combine the results and visualize them
julia --project visualize_mpi.jl

# run with higher resolution
mpiexecjl -n 4 julia --project diffusion_2d_mpi_gpu.jl 16384 nosave
