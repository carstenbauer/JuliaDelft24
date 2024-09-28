# 2D linear diffusion solver - serial, loop version
using Printf
using Plots
include(joinpath(@__DIR__, "shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

function diffusion_step!(params, C2, C)
    (; dx, dy, dt, D) = params
    # respect column major order
    for iy in 1:size(C, 2)-2
        for ix in 1:size(C, 1)-2
            @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) * inv(dx) +
                                                             (@qy(ix+1, iy+1) - @qy(ix+1, iy)) * inv(dy))
        end
    end
    return nothing
end

function run_diffusion(; ns=128, nt=ns^2÷40, do_visualize=false)
    params   = init_params(; ns, nt, do_visualize)
    C, C2    = init_arrays(params)
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
    run_diffusion(; do_visualize)
end
