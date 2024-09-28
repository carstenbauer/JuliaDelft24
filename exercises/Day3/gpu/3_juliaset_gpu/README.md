# Exercise: Julia Set on NVIDIA GPU

**Note: Unless you have a NVIDIA GPU in your laptop, this exercise must be done on a cluster compute node (with NVIDIA V100 GPUs).**

In this exercise, we will revisit the problem of computing an image of the Julia Set. This time we will compare a sequential CPU variant to a parallel GPU implementation (using a custom CUDA kernel).

Remarkable side note: We will use the same `_compute_pixel` function both for the CPU and GPU variants!

You can either work with a Julia script file (see the instructions below) or with a Jupyter notebook (see `juliaset_gpu.ipynb`).

## Tasks

1) The relevant file for this exercise is `juliaset_gpu.jl`. Look for "TODO" blocks therein and complete them.

2) Run the script (e.g. `sbatch job_script.sh`) to benchmark the CPU and GPU variant.

3) Imagine we could parallelize the CPU code perfectly on a full compute node with 128 CPU-cores (e.g. with multithreading).
  - What would be the runtime of this CPU-parallel variant?
  - Would the GPU computation (including data transfer) still be much faster?