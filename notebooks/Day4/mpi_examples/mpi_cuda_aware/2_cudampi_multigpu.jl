# cuda_mpi_test.jl
using MPI
using CUDA

MPI.Init()
comm   = MPI.COMM_WORLD
rank   = MPI.Comm_rank(comm)
size   = MPI.Comm_size(comm)
comm_l = MPI.Comm_split_type(comm, MPI.COMM_TYPE_SHARED, rank)
rank_l = MPI.Comm_rank(comm_l)
# choose correct GPU for this rank
gpu_id = CUDA.device!(rank_l % ndevices())

dst = mod(rank+1, size)
src = mod(rank-1, size)
sleep(0.1*rank)
println("rank $rank of $size (gpu=$(device())): destination=$dst, source=$src")

# allocate memory on the GPU
N = 4
send_mesg = CuArray{Float64}(undef, N)
recv_mesg = CuArray{Float64}(undef, N)
fill!(send_mesg, Float64(rank))

# pass GPU buffers (CuArrays) into MPI functions
MPI.Sendrecv!(send_mesg, dst, 0, recv_mesg, src, 0, comm)
println("recv_mesg on proc $rank: $recv_mesg")
