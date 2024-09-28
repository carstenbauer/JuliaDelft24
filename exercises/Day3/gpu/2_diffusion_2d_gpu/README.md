# Exercise: 2D Diffusion - GPU

**Note: Unless you have a NVIDIA GPU in your laptop, this exercise must be done on a cluster compute node (with NVIDIA V100 GPUs).**

The goal of this exercise is to move the 2D linear diffusion solver from exercise `diffusion_2d_multithreading` to the GPU. Before we start a first (bonus) question:

* Do you think it makes sense to move this computation to the GPU and why?
  * Hint: Look at the computational kernel (`diffusion_step!`) and think about if it is memory or compute bound. Then take into account the results that you've obtained in the `daxpy_cpu` and `saxpy_gpu` exercises.
 
## Task 1: Translation into a CUDA kernel

For convenience, let's recite the serial `diffusion_step!` function (from `diffusion_2d_serial.jl`):

```julia
function diffusion_step!(params, C2, C)
    (; dx, dy, dt, D) = params
    
    for iy in 1:size(C, 2)-2
        for ix in 1:size(C, 1)-2
            @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) * inv(dx) +
                                                             (@qy(ix+1, iy+1) - @qy(ix+1, iy)) * inv(dy))
        end
    end
    
    return nothing
end
```

Your task is to translate this into a custom CUDA kernel.

Note that the CUDA kernel will be run using multiple blocks. In `shared.jl` we set

```julia
nthreads = 32, 8              # number of threads per block
nblocks  = cld.(ns, nthreads) # number of blocks
```

1. Open the file `diffusion_2d_gpu.jl`, find the `diffusion_step_kernel!` function and implement it (see the `TODO` block).
2. Next, focus on the `run_diffusion` function and modify it to ensure that the matrices `C` and `C2` (representing our diffusive quantitiy, e.g. heat) live in GPU memory rather than host memory (see `TODO` block).
3. Finally, make sure that the code is working by running it (`sbatch job_script.sh`) and inspecting the final visualization.
  - **If you have a GPU in your laptop**, you can run the file in an interactive REPL via `include("diffusion_2d_gpu.jl")` or from the command line via `julia --project diffusion_2d_gpu.jl`.

## Task 2: Benchmark

We want to assess the performance of our 2D diffusion solver on the GPU.

1. Look at the file `job_script.sh` and then run it (if you haven't done so already). If you're working on your laptop, use `./job_script.sh` or `sh job_script.sh`. If you're on the cluster, submit the job via `sbatch job_script.sh`.
2. Inspect the results, with the following questions in mind:
  - Does the trend (as a function of increasing `ns`) make sense?
  - How does `T_eff` compare to the serial/multithreaded variants?
  - How does `T_eff` compare to the result obtained in the `saxpy_gpu` exercise?
  - Do you think we can improve the performance much further? Why/why not?
  - Was it a good idea to move to the GPU?