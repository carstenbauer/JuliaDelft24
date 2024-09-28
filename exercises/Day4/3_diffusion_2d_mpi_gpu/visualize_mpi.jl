# Visualisation script for the 2D MPI solver
using Plots
using JLD2

function vizme2D_mpi(nprocs)
    C = []
    lx = ly = 0.0
    ip = 1
    for ipx in 1:nprocs[1]
        for ipy in 1:nprocs[2]
            C_loc, lxy = load("out_$(ip-1).jld2", "C", "lxy")
            nx_i, ny_i = size(C_loc, 1), size(C_loc, 2)
            ix1, iy1 = 1 + (ipx - 1) * nx_i, 1 + (ipy - 1) * ny_i
            if ip == 1
                C = zeros(nprocs[1] * nx_i, nprocs[2] * ny_i)
                lx, ly = lxy
            end
            C[ix1:ix1+nx_i-1, iy1:iy1+ny_i-1] .= C_loc
            ip += 1
        end
    end
    xc, yc = LinRange.(0, (lx, ly), size(C))
    plt = Plots.heatmap(xc, yc, C; clims=(0, 1), c=:turbo, dpi=300)
    isinteractive() && display(fig)
    savefig(plt, "visualization.png")
    return
end

nprocs = begin
    d = isqrt(length(filter(f -> endswith(f, ".jld2") && startswith(f, "out_"), readdir(@__DIR__))))
    (d, d)
end

vizme2D_mpi(nprocs)
