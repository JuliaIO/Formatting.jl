using Formatting
using Base.Test

@testset "cformat" begin include( "cformat.jl" ) end
@testset "fmtspec" begin include( "fmtspec.jl" ) end
@testset "formatexpr" begin include( "formatexpr.jl" ) end
