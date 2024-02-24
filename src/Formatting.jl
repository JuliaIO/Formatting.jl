module Formatting

    import Base.show
    using Printf, Logging

    export
        FormatSpec, FormatExpr,
        printfmt, printfmtln, fmt, format,
        sprintf1, generate_formatter

    function __init__()
        @warn """
        DEPRECATION NOTICE

        This package has been unmaintained for a while, with some serious
        bugs comprimising the original purpose of the package. As a result,
        it has been deprecated - consider using an alternative, such as
        `Format.jl` (https://github.com/JuliaString/Format.jl) or the `Printf` stdlib directly.
        """
    end

    include("cformat.jl" )
    include("fmtspec.jl")
    include("fmtcore.jl")
    include("formatexpr.jl")

end # module
