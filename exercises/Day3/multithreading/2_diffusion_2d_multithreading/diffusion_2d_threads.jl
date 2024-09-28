# 2D linear diffusion solver - multithreading
using Printf
using Plots
using OhMyThreads
include(joinpath(@__DIR__, "shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

function diffusion_step!(params, C2, C)
    (; dx, dy, dt, D, sched) = params
    #
    # TODO: Copy the double-loop from the diffusion_step! function
    #       in diffusion_2d_serial and multithread the outer one.
    #       Use `@tasks` and `@set scheduler = sched` to choose
    #       either the dynamic or static scheduler.
    #       (sched will be either :static or :dynamic)
    # 
    #
    return nothing
end

function run_diffusion(; ns=128, nt=ns^2÷40, do_visualize=false, parallel_init=false, static=false)
    params   = init_params(; ns, nt, do_visualize, parallel_init, static)
    C, C2    = init_arrays_threads(params)
    maybe_visualize(params, C)
    t_tic    = 0.0
    # time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
        # visualization
        maybe_visualize(params, C, it)
    end
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    return nothing
end

# Running things...

# enable visualization by default
(!@isdefined do_visualize) && (do_visualize = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    if !isempty(ARGS)
        # called from the command line with arguments
        static = (length(ARGS) > 1 && ARGS[2] == "static") ? true : false
        run_diffusion(; ns=parse(Int, ARGS[1]), do_visualize=false)
    else
        run_diffusion(; do_visualize)
    end
end
