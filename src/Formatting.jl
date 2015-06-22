module Formatting

    import Base.show

    export
        FormatSpec, FormatExpr,
        printfmt, printfmtln, cfmt, format,
        sprintf1, generate_formatter

    export
        fmt, default!

    using Compat

    include("cformat.jl" )
    include("fmtspec.jl")
    include("fmtcore.jl")
    include("formatexpr.jl")
    include("fmt.jl")

end # module
