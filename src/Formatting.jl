module Formatting

    import Base.show

    export 
        FormatSpec, printfmt, fmt


    include("fmtspec.jl")
    include("fmtcore.jl")

end # module
