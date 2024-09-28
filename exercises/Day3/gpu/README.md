# Exercises - Day 3

### `1_saxpy_gpu`

**Learnings:** using GPU array abstractions, writing a basic CUDA kernel, maximal memory bandwidth (GPU).

You'll try to measure the maximal, obtainable memory bandwidth of a GPU. To that end, you'll consider different GPU implementations of SAXPY. Specifically, you'll move the computation to the GPU using array abstractions and will then hand-write a custom CUDA kernel. Afterwards, you'll compare your variants to a built-in CUBLAS implementation by NVIDIA.

### `2_diffusion_2d_gpu`

**Learnings:** moving an iterative stencil solver to the GPU, strong scaling benchmark

We'll revisit the 2D diffusion example (see `diffusion_2d_multithreaded` above) and translate the multithreaded computation into a CUDA kernel. How much more efficient will the GPU variant be?

### `3_juliaset_gpu`

**Learnings:** CPU and GPU performance, a glimpse at hardware-agnostic coding

In this exercise, we consider the problem of computing an image of the Julia Set. We will compare a CPU variant to a parallel GPU variant (custom CUDA kernel). Both implementations will call the same Julia function.