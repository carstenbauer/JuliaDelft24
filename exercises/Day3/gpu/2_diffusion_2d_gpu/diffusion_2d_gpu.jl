# 2D linear diffusion solver - GPU cuda version
using Printf
using JLD2
using CUDA
using Plots
include(joinpath(@__DIR__, "shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

function diffusion_step_kernel!(params, C2, C)
    (; dx, dy, dt, D) = params
    #
    # TODO: Compute the global indices ix and iy of the GPU-thread.
    #       Use threadIdx().x, blockIdx().x, and blockDim().x (similar for y).
    #
    #       (For inspiration, see the cuda_kernel_blocks! example from the lecture.)
    #
    # ix = ...
    # iy = ...

    #
    # TODO: Convert the loop version of the diffusion kernel (diffusion_2d_serial.jl)
    #       into a CUDA kernel. Specifically, replace the loops by if conditions on
    #       the global GPU-thread indices ix and iy.
    #
    #       (For inspiration, see the cuda_kernel_blocks! example from the lecture.)
    #
    return nothing
end

function diffusion_step!(params, C2, C)
    (; nthreads, nblocks) = params
    @cuda threads = nthreads blocks = nblocks diffusion_step_kernel!(params, C2, C)
    return nothing
end

function run_diffusion(; ns=128, nt=ns^2÷40, do_visualize=false)
    choose_correct_gpu()
    params   = init_params_gpu(; ns, nt, do_visualize)
    C, C2    = init_arrays(params)

    #
    # TODO: Move C and C2 to the GPU by converting them to CuArrays.
    #       (Don't change init_arrays_mpi but simply do X = CuArray(X) for both of them.)
    #

    maybe_visualize(params, C)
    t_tic    = 0.0
    # Time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
        # visualization
        maybe_visualize(params, C, it)
    end
    # synchronize the gpu before querying the final time
    CUDA.synchronize()
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    return nothing
end

# Running things...

# enable saving by default
(!@isdefined do_visualize) && (do_visualize = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    if !isempty(ARGS)
        run_diffusion(; ns=parse(Int, ARGS[1]), nt=500, do_visualize=false)
    else
        run_diffusion(; do_visualize)
    end
end
