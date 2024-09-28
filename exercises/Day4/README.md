# Exercises - Day 4

## Distributed

### `1_montecarlo_pi_distributed`

**Learnings:** basics of distributed computing with Distributed and MPI

In these exercises, you will parallelize a simple Monte Carlo algorithm that can produce the value of π=3.141... with desirable precision. Specifically, you will parallelize the algorithm und MPI.jl and Distributed.jl.

### `2_diffusion_2d_mpi`

**Learnings:** solving a physical (stencil) problem in parallel with MPI, weak scaling benchmark

We revisit the 2D diffusion example from yesterday and parallelize it using MPI. In principle, this enables us to run the code at scale. We will switch from a strong scaling to a weak scaling approach.

### `5_diffusion_2d_mpi_gpu` (cluster only)

**Learnings:** solving a physical (stencil) problem in parallel with MPI on multiple GPUs

We revisit the 2D diffusion example once more and parallelize it using MPI + CUDA. In principle, this enables us to run the code on multiple GPUs, potentially in different compute nodes, at scale.
