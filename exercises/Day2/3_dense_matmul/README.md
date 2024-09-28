# Exercise: (Dense) Matrix-Matrix Multiplication

In this exercise you will consider dense matrix-matrix multiplication

$C_{rc} = \sum_{k=1}^{n} A_{rk} B_{kc}$

for square matrices $A$, $B$, and $C$ of size $n \times n$. Despite being seemingly simple, you will see that different implementations have vastly different performance.

**Note: Ideally, this exercise should be done on a cluster compute node (but it's not required). You can either follow the instructions below or use the Jupyter notebook `dense_matmul.ipynb`.**

## Tasks

You can/should work with the file `dense_matmul.jl`, which contains the implementations mentioned below.

1) Benchmark the naive implementation `matmul_naive!` in GFLOPS (giga floating-point operations per second). The `main` function already contains the benchmark code. (You can submit a compute job via `sbatch job_script.sh`.)
2) Why is `matmul_naive!` so slow?
    * Hints: Look at the memory access pattern of innermost loop.
3) Implement an improved version with contiguous memory access (better spatial locality) in `matmul_contiguous!` and benchmark it. How much faster is it?

### Cache Blocking

The key idea of cache blocking is to perform the overall matrix-matrix multiplication in terms of smaller matrix-matrix multiplications of sub-blocks.

<img src="./imgs/dMMM_cache_blocking.png">
<br>

4) Inspect the given variant `matmul_cache_blocking!` which implements cache blocking.
    * In which limit, that is, for what block size values, does the code semantically reduce to your code in 3)?
    * Staying away from these limits, how can this implementation be faster?
5) Benchmark the cache blocking variant. Specifically, consider `c_blksize = 16`, `r_blksize = 128` and `k_blksize = 16` for the block sizes.
    * Can you give an argument why it makes sense to choose `r_blksize` larger than the others?
    * How big (in bytes) are the blocks for `A` and `C` for these values? How does this compare to a L1 cache size of 32 KiB? 
6) Compare the cache-blocking variant to built-in BLAS matrix multiply, i.e. `mul!(C, A, B)`.
    * Note: `using LinearAlgebra` is required for `mul!` to be available. (Make sure to set `BLAS.set_num_threads(1)`.)
7) **Bonus:** vary the block sizes (in powers of 2) and see how the performance changes.

