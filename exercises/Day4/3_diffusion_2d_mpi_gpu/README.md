# Exercise: Diffusion 2D - Multi-GPU (cluster only)

The goal of this exercise is to combine the results from the previous exercises `diffusion_2d_gpu` (yesterday) and `diffusion_2d_mpi` (today) to obtain a scalable variant of the 2D diffusion solver that can run on many GPUs, either in one node or distributed among multiple nodes.

**NOTE 1:** For two reasons, this only works on the cluster.
1. The MPI that MPI.jl ships automatically (what you're using) isn't CUDA-aware.
2. I'd be surprised if you have more than one GPU in your laptop.

**Note 2:** For simplicity, and due to limited resources, we will only run the MPI+GPU code on a single compute node (with multiple GPUs in it).

## Task 1

The strategy is straightforward: take the general setup of the MPI simulation (`diffusion_2d_mpi.jl`) and make each MPI rank run the CUDA kernel from `diffusion_2d_gpu.jl`. We will use one GPU per MPI rank.

1. Follow the instructions in the `TODO` blocks in the file `diffusion_2d_mpi_gpu.jl`.
2. Use `sbatch job_script.sh` to run the code with 4 MPI ranks and to create a visualization of the result (`visualization.png`). Inspect the latter to make sure that everything is working correctly.

## Task 2

Let's increase the problem size and run a benchmark of our multi-GPU 2D diffusion solver.

1. Uncomment the last line in `job_script.sh`, which runs the code for a larger value of `ns` (higher grid resolution) and does not save the results on disk.
2. Submit the job via `sbatch job_script.sh`.
3. Inspect the results.
    - What value for `T_eff` do you obtain?
    - How does it compare to our previous results (pure MPI, pure GPU)?