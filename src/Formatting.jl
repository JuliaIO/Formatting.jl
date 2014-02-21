module Formatting

    import Base.show

    export 
        FormatSpec, FormatExpr, 
        printfmt, printfmtln, fmt, format


    include("fmtspec.jl")
    include("fmtcore.jl")
    include("formatexpr.jl")

end # module
