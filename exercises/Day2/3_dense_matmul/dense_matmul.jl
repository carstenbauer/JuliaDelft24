using BenchmarkTools
using CpuId
using Test
using LinearAlgebra
BLAS.set_num_threads(1)

# ---
# Naive
# ---
function matmul_naive!(C, A, B)
    @assert size(C) == size(A) == size(B)
    @assert size(C, 1) == size(C, 2)
    n = size(C, 1)
    fill!(C, zero(eltype(C)))

    # - c: for columns of B and C
    # - r: for rows    of A and C
    # - k: for columns of A and rows of B
    for c in 1:n
        for r in 1:n
            c_reg = 0.0
            for k in 1:n
                @inbounds c_reg += A[r, k] * B[k, c]
            end
            @inbounds C[r, c] = c_reg
        end
    end
    return C
end


# ---
# Contiguous
# ---
function matmul_contiguous!(C, A, B)
    @assert size(C) == size(A) == size(B)
    @assert size(C, 1) == size(C, 2)
    n = size(C, 1)
    fill!(C, zero(eltype(C)))

    # - c: for columns of B and C
    # - r: for rows    of A and C
    # - k: for columns of A and rows of B

    #
    # TODO: Implement improved version with more efficient memory access / better localitly.
    #       Hint: Which loop should be the innermost?
    #
    return C
end


# ---
# Cache blocking
# ---
function matmul_cache_blocking!(C, A, B; col_blksize=16, row_blksize=128, k_blksize=16)
    @assert size(C) == size(A) == size(B)
    @assert size(C, 1) == size(C, 2)
    n = size(C, 1)
    fill!(C, zero(eltype(C)))

    # - c: for columns of B and C
    # - r: for rows    of A and C
    # - k: for columns of A and rows of B
    for ic in 1:col_blksize:n
        for ir in 1:row_blksize:n
            for ik in 1:k_blksize:n
                #
                # begin: cache blocking
                #
                for jc in ic:min(ic + col_blksize - 1, n)
                    for jk in ik:min(ik + k_blksize - 1, n)
                        @inbounds b = B[jk, jc]
                        for jr in ir:min(ir + row_blksize - 1, n)
                            @inbounds C[jr, jc] += A[jr, jk] * b
                        end
                    end
                end
                #
                # end: cache blocking
                #
            end
        end
    end
    return C
end


function main()
    # problem size (tune this if necessary)
    if length(ARGS) > 0
        N = parse(Int, first(ARGS))
    else
        N = 512
    end
    # input (not to be modified)
    C = zeros(N, N)
    A = rand(N, N)
    B = rand(N, N)

    # naive
    @test matmul_naive!(C, A, B) ≈ mul!(similar(C), A, B)
    t_naive = @belapsed matmul_naive!($C, $A, $B) samples = 1 evals = 2
    println("matmul_naive!: ", t_naive, " sec, performance = ", round(2.0e-9 * N^3 / t_naive, digits=2), " GFLOP/s")

    # contiguous
    # @test matmul_contiguous!(C, A, B) ≈ mul!(similar(C), A, B) # this should give true, otherwise your implementation is incorrect.
    # t_contiguous = @belapsed matmul_contiguous!($C, $A, $B) samples = 1 evals = 2
    # println("matmul_contiguous!: ", t_contiguous, " sec, performance = ", round(2.0e-9 * N^3 / t_contiguous, digits=2), " GFLOP/s")

    # cache blocking
    # @test matmul_cache_blocking!(C, A, B) ≈ mul!(similar(C), A, B)
    # t_cache_blocking = @belapsed matmul_cache_blocking!($C, $A, $B) samples = 1 evals = 2
    # println("matmul_cache_blocking!: ", t_cache_blocking, " sec, performance = ", round(2.0e-9 * N^3 / t_cache_blocking, digits=2), " GFLOP/s")

    # BLAS matmul (for comparison)
    # t_BLAS = @belapsed mul!($C, $A, $B) samples = 1 evals = 2
    # println("mul! (BLAS): ", t_BLAS, " sec, performance = ", round(2.0e-9 * N^3 / t_BLAS, digits=2), " GFLOP/s")

    # bonus: varying block size
    # println("Varying block sizes:")
    # L1 = cachesize()[1]
    # for cbs in (4, 8, 16, 32, 64), kbs in (4, 8, 16, 32, 64), rbs in (4, 128, 256, 512)
    #     if rbs * kbs + rbs * cbs > L1 / 8
    #         # A block and C block don't fit into L1 cache together
    #         continue
    #     end
    #     t_cache_block = @belapsed matmul_cache_blocking!($C, $A, $B; col_blksize=$cbs, row_blksize=$rbs, k_blksize=$kbs) samples = 1 evals = 2
    #     println("matmul_cache_block ($cbs, $rbs, $kbs): ", t_cache_block, " sec, performance = ", round(2.0e-9 * N^3 / t_cache_block, digits=2), " GFLOPS\n")
    # end
end

@time main()
