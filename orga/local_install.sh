#
# to be executed in the HOME directory of the user accounts on the HLRS laptops
#

# install juliaup + julia (if julia doesn't already exist)
if ! command -v julia &> /dev/null
then
    echo "julia could not be found, installing juliaup + julia ..."
    curl -fsSL https://install.julialang.org | sh -s -- --yes
fi

# install workshop environment (includes LIKWID)
git clone https://github.com/carstenbauer/JuliaHLRS24
cd JuliaHLRS24
julia install.jl full
