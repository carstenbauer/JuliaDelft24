# 2D linear diffusion solver - MPI
using Printf
using JLD2
using MPI
using CUDA
include(joinpath(@__DIR__, "shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

#
# TODO: Copy the implementations of the functions diffusion_step_kernel! and
#       diffusion_step! from the diffusion_2d_gpu exercise (take them from the
#       solutions if necessary) and paste them here.
#

#
# TODO: Copy the implementations of the functions update_halo! and
#       init_bufs! from the diffusion_2d_mpi exercise (take them from the
#       solutions if necessary) and paste them here.
#
#       Afterwards, in init_bufs!, replace all calls zeros(size(A, i)) by
#       CUDA.zeros(Float64, size(A, i)). This ensures that our buffers are on the GPU
#       rather than in host memory.
#

function run_diffusion(; ns=128, nt=1000, do_save=false)
    # arrange MPI ranks in a cartesian grid
    MPI.Init()
    comm      = MPI.COMM_WORLD
    nprocs    = MPI.Comm_size(comm)
    dims      = MPI.Dims_create(nprocs, (0, 0)) |> Tuple
    comm_cart = MPI.Cart_create(comm, dims)
    rank      = MPI.Comm_rank(comm_cart)
    coords    = MPI.Cart_coords(comm_cart) |> Tuple
    x_neighs  = MPI.Cart_shift(comm_cart, 1, 1)
    y_neighs  = MPI.Cart_shift(comm_cart, 0, 1)
    neighbors = (; left=x_neighs[1], right=x_neighs[2], up=y_neighs[1], down=y_neighs[2])

    # Select GPU on multi-GPU system based on shared memory topology
    comm_l    = MPI.Comm_split_type(comm, MPI.COMM_TYPE_SHARED, rank)
    rank_l    = MPI.Comm_rank(comm_l)
    # set GPU if more than one device is present
    gpu_id    = CUDA.device!(rank_l % ndevices())
    println("$(gpu_id), out of: $(ndevices())")

    (rank == 0) && println("nprocs = $(nprocs), dims = $dims")

    params = init_params_gpu_mpi(; dims, coords, ns, nt, do_save)
    C, C2  = init_arrays_mpi(params)

    #
    # TODO: Move C and C2 to the GPU by making them CuArrays.
    #       (Don't change init_arrays_mpi but simply do X = CuArray(X) for both of them.)
    #

    bufs   = init_bufs(C)
    t_tic  = 0.0
    # time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        update_halo!(C2, bufs, neighbors, comm_cart)
        C, C2 = C2, C # pointer swap
    end
    # synchronize the gpu before querying the final time
    CUDA.synchronize()
    t_toc = (Base.time() - t_tic)
    # "master" prints performance
    (rank == 0) && print_perf(params, t_toc)
    # save to (maybe) visualize later
    if do_save
        jldsave(joinpath(@__DIR__, "out_$(rank).jld2"); C = Array(C[2:end-1, 2:end-1]), lxy = (; lx=params.L, ly=params.L))
    end
    MPI.Finalize()
    return nothing
end

# Running things...

# enable save to disk by default
(!@isdefined do_save) && (do_save = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    if !isempty(ARGS)
        do_save = !(length(ARGS) > 1 && ARGS[2] == "nosave")
        run_diffusion(; ns=parse(Int, ARGS[1]), do_save)
    else
        run_diffusion(; do_save)
    end
end
