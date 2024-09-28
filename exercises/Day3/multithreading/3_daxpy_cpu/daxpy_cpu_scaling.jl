using BenchmarkTools
using PrettyTables
using Random
using ThreadPinning
using Base.Threads
using OhMyThreads
using Plots

if nthreads() != ncores()
    println("ERROR: This exercise is supposed to be run with $(ncores()) Julia threads! Aborting.")
    exit(42)
end

const ncores_per_numa   = count(i->!ishyperthread(i), numa(1))
const ncores_per_socket = count(i->!ishyperthread(i), socket(1))

function axpy_static_chunks!(y, a, x; chunks)
    @tasks for idcs in chunks
        @set scheduler=:static
        @simd for i in idcs
            @inbounds y[i] = a * x[i] + y[i]
        end
    end
    return nothing
end

function generate_input_data_chunks(; N, dtype, parallel=false, chunks, kwargs...)
    a = dtype(3.141)
    x = Vector{dtype}(undef, N)
    y = Vector{dtype}(undef, N)
    if !parallel
        rand!(x)
        rand!(y)
    else
        @tasks for idcs in chunks
            @set scheduler=:static
            @inbounds for i in idcs
                x[i] = rand()
                y[i] = rand()
            end
        end
    end
    return a,x,y
end

default_N(dtype) = floor(Int, (1/8 * Sys.total_memory()) / (2 * sizeof(dtype)))

function measure_perf_chunks(; dtype=Float64, N=default_N(dtype), numthreads=nthreads(), kwargs...)
    # input data
    cs = index_chunks(1:N; n=numthreads)
    a, x, y = generate_input_data_chunks(; N, dtype, chunks=cs, kwargs...)

    # time measurement
    t = @belapsed axpy_static_chunks!($y,$a,$x; chunks=$cs) evals = 4 samples = 5

    # compute memory bandwidth and flops
    bytes = 3 * sizeof(dtype) * N
    flops = 2 * N
    mem_rate = bytes * 1e-9 / t
    flop_rate = flops * 1e-9 / t
    return mem_rate, flop_rate
end

function axpy_scaling_table(; numthreads=1:nthreads(), kwargs...)
    for nt in numthreads
        membw_results = Matrix{Float64}(undef, 3, 2)
        for (i, pin) in enumerate((:cores, :sockets, :numa))
            for (j, parallel) in enumerate((false, true))
                pinthreads(pin)
                membw, flops = measure_perf_chunks(; numthreads=nt, parallel=parallel, kwargs...)
                membw_results[i, j] = round(membw; digits=2)
            end
        end

        # (pretty) printing
        println()
        pretty_table(membw_results;
            header=[":serial", ":parallel"],
            row_labels=[":cores", ":sockets", ":numa"],
            row_label_column_title="# Threads = $nt",
            title="Memory Bandwidth (GB/s)")
        flush(stdout)
    end
end

function axpy_scaling_plot(; numthreads=1:nthreads(), kwargs...)
    membws = Dict{Symbol, Vector{Float64}}()
    membws[:cores] = zeros(length(numthreads))
    membws[:sockets] = zeros(length(numthreads))
    membws[:numa] = zeros(length(numthreads))

    for (t, nt) in enumerate(numthreads)
        for (p, pin) in enumerate((:cores, :sockets, :numa))
            pinthreads(pin)
            membw, flops = measure_perf_chunks(; numthreads=nt, parallel=true, kwargs...)
            membws[pin][t] = round(membw; digits=2)
        end
    end

    props = (marker=:circle, ms=5, lw=1.5)
    p = plot(numthreads, membws[:numa]; label=":numa", props...,
        frame=:box,
        xlabel="number of threads",
        ylabel="memory bandwidth [GB/s]",
        size=(700,450),
        xlim=(0,ncores()+1),
        xticks=[1,ncores_per_numa,ncores_per_socket,ncores()],
        tickfontsize=12,
        guidefontsize=13,
        legendfontsize=12,
        linewidth=1.5)
    plot!(p, numthreads, membws[:sockets]; props..., label=":sockets")
    plot!(p, numthreads, membws[:cores]; props..., label=":cores")

    if maximum(numthreads) > ncores_per_socket
        vline!(p, [ncores_per_socket]; ls=:dash, color=:grey, lw=1.5, label=nothing)
    end

    savefig("scaling_plot.svg")
    return nothing
end

function main()
    @time axpy_scaling_table(; numthreads=unique([1, ncores_per_numa, ncores_per_socket, ncores()]))
    if ncores_per_numa < ncores_per_socket
        n = ncores_per_numa ÷ 2
    else
        n = ncores_per_socket ÷ 4
    end
    @time axpy_scaling_plot(; numthreads=[1; n:n:ncores()])
end

@time main() # can take some time
