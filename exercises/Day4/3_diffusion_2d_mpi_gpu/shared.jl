## PARAMETER INITIALIZATION
function init_params_gpu_mpi(; dims, coords, ns=128, nt=ns^2÷40, kwargs...)
    L    = 10.0                      # physical domain length
    D    = 1.0                       # diffusion coefficient
    nx_g = dims[1] * (ns - 2) + 2    # global number of grid points along dim 1
    ny_g = dims[2] * (ns - 2) + 2    # global number of grid points along dim 2
    dx   = L / nx_g                  # grid spacing
    dy   = L / ny_g                  # grid spacing
    dt   = min(dx, dy)^2 / D / 4.1   # time step
    x0   = coords[1] * (ns - 2) * dx # coords shift to get global coords on  local process
    y0   = coords[2] * (ns - 2) * dy # coords shift to get global coords on  local process
    xcs  = LinRange(x0 + dx / 2, x0 + ns * dx - dx / 2, ns) .- 0.5 * L # local vector of global coord points
    ycs  = LinRange(y0 + dy / 2, y0 + ns * dy - dy / 2, ns) .- 0.5 * L # local vector of global coord points
    nthreads = 32, 8                 # number of threads per block
    nblocks  = cld.(ns, nthreads)    # number of blocks
    return (; L, D, ns, nt, dx, dy, dt, xcs, ycs, nthreads, nblocks, kwargs...)
end

## ARRAY INITIALIZATION
function init_arrays_mpi(params)
    (; xcs, ycs) = params
    C  = @. exp(-xcs^2 - (ycs')^2)
    C2 = copy(C)
    return C, C2
end

## VISUALIZATION & PRINTING
function print_perf(params, t_toc)
    (; ns, nt) = params
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n\n", t_toc, round((2 / 1e9 * ns^2 * sizeof(Float64)) / (t_toc / (nt - 10)), sigdigits=6))
    return nothing
end
