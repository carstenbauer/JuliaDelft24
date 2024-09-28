# Exercises - Day 3

### `1_montecarlo_pi_multithreading`

**Learnings:** multithreading a simple algorithm, uniform and non-uniform workload, nested multithreading

In this exercise, you will parallelize the famous Monte Carlo algorithm that can produce the value of π=3.141... with desirable precision. Specifically, you will parallelize the algorithm using Julia's multithreading tools (e.g. `@spawn`).

### `2_diffusion_2d_multithreading`

**Learnings:** solving a physical (stencil) problem in parallel, strong scaling benchmark.

Considering the 2D diffusion equation, you will implement a multithreaded, iterative stencil solver for the differential equation. The solver is based on Euler's method and finite differences.

**Note:** Later in the course, we will come back to this very solver and (1) move it to the GPU and (2) parallelize it with MPI, to run it on multiple compute nodes (and multiple GPUs).

### `3_daxpy_cpu` (cluster only)

**Learnings:** NUMA domains, thread pinning, maximal memory bandwidth.

You'll consider a multithreaded DAXPY kernel and will study how thread pinning and (implicit) memory pinning can influence the performance dramatically. Using the DAXPY kernel, you will estimate the maximal memory bandwidth (GB/s) of the system.
