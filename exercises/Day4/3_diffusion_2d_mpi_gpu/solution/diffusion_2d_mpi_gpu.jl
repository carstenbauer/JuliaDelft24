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
# TODO: Copy the definitions of the functions diffusion_step_kernel! and
#       diffusion_step! from the diffusion_2d_gpu exercise (take them from the
#       solutions if necessary) and paste them here.
#
function diffusion_step_kernel!(params, C2, C)
    (; dx, dy, dt, D) = params
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # CUDA vectorised unique index
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # CUDA vectorised unique index
    if ix <= size(C, 1)-2 && iy <= size(C, 2)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix + 1, iy + 1) - @qx(ix, iy + 1)) * inv(dx) +
                                                         (@qy(ix + 1, iy + 1) - @qy(ix + 1, iy)) * inv(dy))
    end
    return nothing
end

function diffusion_step!(params, C2, C)
    (; nthreads, nblocks) = params
    @cuda threads = nthreads blocks = nblocks diffusion_step_kernel!(params, C2, C)
    return nothing
end

#
# TODO: Copy the definitions of the functions update_halo! and
#       init_bufs! from the diffusion_2d_mpi exercise (take them from the
#       solutions if necessary) and paste them here.
#
#       Afterwards, in init_bufs!, replace all calls zeros(size(A, i)) by
#       CUDA.zeros(Float64, size(A, i)). This ensures that our buffers are on the GPU
#       rather than in host memory.
#
# MPI functions
function update_halo!(A, bufs, neighbors, comm)
    # x-dimension
    (neighbors.left  != MPI.PROC_NULL) && copyto!(bufs.send_left,  @view(A[:, 2    ]))
    (neighbors.right != MPI.PROC_NULL) && copyto!(bufs.send_right, @view(A[:, end-1]))

    reqs = MPI.MultiRequest(4)
    (neighbors.left  != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_left,  comm, reqs[1]; source=neighbors.left)
    (neighbors.right != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_right, comm, reqs[2]; source=neighbors.right)

    (neighbors.left  != MPI.PROC_NULL) && MPI.Isend(bufs.send_left,  comm, reqs[3]; dest=neighbors.left)
    (neighbors.right != MPI.PROC_NULL) && MPI.Isend(bufs.send_right, comm, reqs[4]; dest=neighbors.right)
    MPI.Waitall(reqs) # blocking

    (neighbors.left  != MPI.PROC_NULL) && copyto!(@view(A[:, 1  ]), bufs.recv_left)
    (neighbors.right != MPI.PROC_NULL) && copyto!(@view(A[:, end]), bufs.recv_right)

    # y-dimension
    (neighbors.up   != MPI.PROC_NULL) && copyto!(bufs.send_up,   @view(A[2    , :]))
    (neighbors.down != MPI.PROC_NULL) && copyto!(bufs.send_down, @view(A[end-1, :]))

    reqs = MPI.MultiRequest(4)
    (neighbors.up   != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_up,   comm, reqs[1]; source=neighbors.up)
    (neighbors.down != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_down, comm, reqs[2]; source=neighbors.down)

    (neighbors.up   != MPI.PROC_NULL) && MPI.Isend(bufs.send_up,   comm, reqs[3]; dest=neighbors.up)
    (neighbors.down != MPI.PROC_NULL) && MPI.Isend(bufs.send_down, comm, reqs[4]; dest=neighbors.down)
    MPI.Waitall(reqs) # blocking

    (neighbors.up   != MPI.PROC_NULL) && copyto!(@view(A[1  , :]), bufs.recv_up)
    (neighbors.down != MPI.PROC_NULL) && copyto!(@view(A[end, :]), bufs.recv_down)
    return nothing
end

function init_bufs(A)
    return (; send_up   = CUDA.zeros(Float64, size(A, 2)), send_down  = CUDA.zeros(Float64, size(A, 2)),
              send_left = CUDA.zeros(Float64, size(A, 1)), send_right = CUDA.zeros(Float64, size(A, 1)),
              recv_up   = CUDA.zeros(Float64, size(A, 2)), recv_down  = CUDA.zeros(Float64, size(A, 2)),
              recv_left = CUDA.zeros(Float64, size(A, 1)), recv_right = CUDA.zeros(Float64, size(A, 1)))
end

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

    # select GPU on multi-GPU system based on shared memory topology
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
    C = CuArray(C)
    C2 = CuArray(C2)

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
