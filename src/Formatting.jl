module Formatting

    import Base.show
    using Printf, Logging

    export
        FormatSpec, FormatExpr,
        printfmt, printfmtln, fmt, format,
        sprintf1, generate_formatter

    if ccall(:jl_generating_output, Cint, ()) == 1
        @warn """
        DEPRECATION NOTICE

        Formatting.jl has been unmaintained for a while, with some serious
        correctness bugs compromising the original purpose of the package. As a result,
        it has been deprecated - consider using an alternative, such as
        `Format.jl` (https://github.com/JuliaString/Format.jl) or the `Printf` stdlib directly.

        If you are not using Formatting.jl as a direct dependency, please consider
        opening an issue on any packages you are using that do use it as a dependency.
        From Julia 1.9 onwards, you can query `]why Formatting` to figure out which
        package originally brings it in as a dependency.
        """
    end

    include("cformat.jl" )
    include("fmtspec.jl")
    include("fmtcore.jl")
    include("formatexpr.jl")

end # module
