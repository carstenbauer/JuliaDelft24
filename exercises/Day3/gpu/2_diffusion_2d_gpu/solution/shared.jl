## PARAMETER INITIALIZATION
function init_params_gpu(; ns=64, nt=ns^2÷40, kwargs...)
    L    = 10.0                   # physical domain length
    D    = 1.0                    # diffusion coefficient
    dx   = L / ns                 # grid spacing
    dy   = L / ns                 # grid spacing
    dt   = (dx * dy) / D / 4.1         # time step
    cs   = range(start=dx / 2, stop=L - dx / 2, length=ns) .- 0.5 * L # vector of coord points
    nout = floor(Int, nt / 5)     # plotting frequency
    nthreads = 32, 8              # number of threads per block
    nblocks  = cld.(ns, nthreads) # number of blocks
    return (; L, D, ns, nt, dx, dy, dt, cs, nout, nthreads, nblocks, kwargs...)
end

## ARRAY INITIALIZATION
function init_arrays(params)
    (; cs) = params
    C  = @. exp(-cs^2 - (cs')^2)
    C2 = copy(C)
    return C, C2
end

## VISUALIZATION & PRINTING
function maybe_visualize(params, C, it=0)
    if params.do_visualize && (it % params.nout == 0)
        p = it ÷ params.nout
        plt = Plots.heatmap(params.cs, params.cs, Array(C); clims=(0,1), c=:turbo, dpi=300)
        isinteractive() && display(plt)
        savefig(plt, "visualization_$p.png")
    end
    return nothing
end

function print_perf(params, t_toc)
    (; ns, nt) = params
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * ns^2 * sizeof(Float64)) / (t_toc / (nt - 10)), sigdigits=6))
    return nothing
end

using ThreadPinning
using SysInfo

function choose_correct_gpu()
    # PBS doesn't manage GPUs on the training cluster :(
    # Here, we try to deduce the correct GPU from the assigned CPU cores.
    haskey(ENV, "PBS_O_WORKDIR") || return # not within a PBS job
    mask = getaffinity()
    cpuids = ThreadPinning.Utility.affinitymask2cpuids(mask)
    coreids = SysInfo.Internals.cpuid_to_core.(cpuids)
    gpuids = floor.(Int, (coreids .- 1) ./ 4)
    gpuid = minimum(gpuids)
    CUDA.device!(gpuid)
    println("Prologue: PBS assigned coreids = $(coreids).")
    println("Prologue: Will use GPU $(gpuid+1) ($(uuid(device()))).")
    return
end
