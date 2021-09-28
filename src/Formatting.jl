module Formatting

    import Base.show
    using Printf

    export
        FormatSpec, FormatExpr,
        printfmt, printfmtln, fmt, format,
        sprintf1, generate_formatter

    const THOUSANDS_SEPARATOR = Ref(',')

    include("cformat.jl" )
    include("fmtspec.jl")
    include("fmtcore.jl")
    include("formatexpr.jl")

end # module
