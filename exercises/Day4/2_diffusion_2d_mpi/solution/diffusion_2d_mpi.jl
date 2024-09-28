# 2D linear diffusion solver - MPI
using Printf
using JLD2
using MPI
include(joinpath(@__DIR__, "shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

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

# MPI functions
function update_halo!(A, bufs, neighbors, comm)
    #
    # !!! TODO
    #
    # Complete the halo exchange implementation below. Use non-blocking
    # MPI communication (Irecv! and Isend) at the positions marked by "TODO..." below.
    #
    # Note that `reqs` holds 4 request objects that should be passed as the third
    # positional argument to the Irecv! or Isend call, i.e.
    #      MPI.Irecv!(bufs.recv_whatever, comm, reqs[i]; source=neighbors.whatever)
    #      MPI.Isend(bufs.send_whatever, comm, reqs[i]; dest=neighbors.whatever)
    # respectively, where i ∈ 1:4. This allows us to later wait until all of these
    # requests were processed.
    #

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
    (neighbors.up   != MPI.PROC_NULL) && copyto!(bufs.send_up,    @view(A[2    , :]))
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
    return (; send_up   = zeros(size(A, 2)), send_down  = zeros(size(A, 2)),
              send_left = zeros(size(A, 1)), send_right = zeros(size(A, 1)),
              recv_up   = zeros(size(A, 2)), recv_down  = zeros(size(A, 2)),
              recv_left = zeros(size(A, 1)), recv_right = zeros(size(A, 1)))
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
    (rank == 0) && println("nprocs = $(nprocs), dims = $dims")

    params = init_params_mpi(; dims, coords, ns, nt, do_save)
    C, C2  = init_arrays_mpi(params)
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
