if get(ARGS,1,"Array") == "CuArray"
    using CUDA
    const ArrayType = CUDA.CuArray
else
    const ArrayType = Array
end

include(joinpath("testhelper.jl"))

include("problems.jl")

include("basic.jl")
include("callbacks.jl")

#=
@testset "ODE Tests: Basic" begin
    runmpi(joinpath(@__DIR__, "basic.jl"))
end
=#
# FIXME: Should consolodate all convergence tests into single
# testset --- this test is slightly redundant
# @testset "ODE Tests: Convergence" begin
#     runmpi(joinpath(@__DIR__, "ode_tests_convergence.jl"))
# end
