# uncomment this if you are on cluster gpu node
# ml julia
# ml nvidia/nvhpc
# ml compiler/nvidia
# export OMPI_MCA_mpi_cuda_support=0
# export OMPI_MCA_btl_openib_warn_no_device_params_found=0

for f in *.jl
do
    echo "Running $f"
    mpiexecjl --project -n 5 julia "$f"
done
