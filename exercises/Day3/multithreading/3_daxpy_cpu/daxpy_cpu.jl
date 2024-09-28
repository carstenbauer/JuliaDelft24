using BenchmarkTools
using PrettyTables
using Random
using ThreadPinning
using Base.Threads
using OhMyThreads

const ncores_per_numa   = count(i->!ishyperthread(i), numa(1))
const desired_nthreads  = max(ncores_per_numa, nnuma())

if nthreads() != desired_nthreads
    println("ERROR: This exercise is supposed to be run with $(desired_nthreads) Julia threads! Aborting.")
    exit(42)
end

function axpy_kernel_dynamic!(y, a, x)
    #
    # TODO: Implement the AXPY kernel by looping over all elements of x/y.
    #       Parallelize the loop with `@tasks`.
    #       Use `@inbounds` to elide bound checks.
    #
    return nothing
end

function axpy_kernel_static!(y, a, x)
    #
    # TODO: Implement the AXPY kernel (similar to above) but this time
    #       use the static scheduler, i.e. `@set scheduler=:static`.
    #       Moreover, use `@inbounds` to elide bound checks.
    #
    return nothing
end

function generate_input_data(; N, dtype, parallel=false, static=false, kwargs...)
    a = dtype(3.141)
    x = Vector{dtype}(undef, N)
    y = Vector{dtype}(undef, N)
    if !parallel
        rand!(x)
        rand!(y)
    else
        sched = static ? :static : :dynamic
        #
        # TODO: Parallelize the following initialization. Use `@tasks` and `@set scheduler=sched`.
        #
        for i in eachindex(x)
            x[i] = rand(dtype)
            y[i] = rand(dtype)
        end
    end
    return a,x,y
end

default_N(dtype) = floor(Int, (1/8 * Sys.total_memory()) / (2 * sizeof(dtype)))

function measure_perf(; dtype=Float64, N=default_N(dtype), static=true, kwargs...)
    # input data
    a,x,y = generate_input_data(; N, dtype, static, kwargs...)

    # time measurement
    if static
        t = @belapsed axpy_kernel_static!($y,$a,$x) evals = 5 samples = 10
    else
        t = @belapsed axpy_kernel_dynamic!($y,$a,$x) evals = 5 samples = 10
    end

    # compute memory bandwidth and flops
    bytes     = 3 * sizeof(dtype) * N    # num bytes transferred in AXPY kernel (all iterations)
    flops     = 2 * N                    # num flops performed in AXPY kernel (all iterations)
    mem_rate  = bytes * 1e-9 / t         # memory bandwidth in GB/s
    flop_rate = flops * 1e-9 / t         # flops in GFLOP/s

    return mem_rate, flop_rate
end

function main()
    for static in (false, true)
        println("\nAXPY with scheduler = ", static ? ":static" : ":dynamic")
        membw_results = Matrix{Float64}(undef, 3, 2)
        for (i, pin) in enumerate((:cores, :sockets, :numa))
            for (j, parallel) in enumerate((false, true))
                pinthreads(pin)
                membw, flops = measure_perf(; parallel, static)
                membw_results[i, j] = round(membw; digits=2)
            end
        end

        # (pretty) printing
        println()
        pretty_table(membw_results;
            header=[":serial", ":parallel"],
            row_labels=[":cores", ":sockets", ":numa"],
            row_label_column_title="# Threads = $(nthreads())",
            title="Memory Bandwidth (GB/s)")
        println()
    end
end

@time main()
