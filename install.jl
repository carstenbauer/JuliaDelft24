isoncluster() = isdir("/projects/julia/modulefiles")
if isoncluster()
    @show Base.get_preferences()
end

using Pkg
println("\n\n\tActivating environment in $(pwd())...")
Pkg.activate(@__DIR__)
println("\n\n\tInstantiating environment... (i.e. downloading + precompiling packages)");
Pkg.instantiate()
Pkg.precompile()

Pkg.build("IJulia") # to be safe
Pkg.precompile()

println("\n\n\tDownloading CUDA artifacts (if necessary)", isoncluster() ? " and precompiling the runtime" : "", " ...");
using CUDA
if isoncluster()
    CUDA.precompile_runtime()
    if CUDA.functional()
        CUDA.versioninfo()
    end
end

println("\n\n\tInstalling mpiexecjl ...");
using MPI
MPI.install_mpiexecjl(; force=true)
println("\n\n\t!!!!!!!!!!\n\tYou need to manually put mpiexecjl on PATH. Put the following into your .bashrc (or similar):");
println("\t\texport PATH=$(joinpath(DEPOT_PATH[1], "bin")):\$PATH");
println("\t!!!!!!!!!!")

if length(ARGS) == 1 && ARGS[1] == "full" && (Sys.islinux() || Sys.isapple())
    println("\n\n\t -- FULL MODE: Modifying `.bashrc`/`.zshrc` ...!")
    bashrc = joinpath(ENV["HOME"], ".bashrc")
    zshrc = joinpath(ENV["HOME"], ".zshrc")
    if isfile(bashrc)
        entry = "\nexport PATH=$(joinpath(first(DEPOT_PATH), "bin")):\$PATH\n"
        open(bashrc, "a") do f
            write(f, entry)
        end
    else
        println("\t\t `.bashrc` not found. Skipping!")
    end
    if isfile(zshrc)
        entry = "\nexport PATH=$(joinpath(first(DEPOT_PATH), "bin")):\$PATH\n"
        open(zshrc, "a") do f
            write(f, entry)
        end
    else
        println("\t\t `.zshrc` not found. Skipping!")
    end
end

println("\n\n\tDone!")
