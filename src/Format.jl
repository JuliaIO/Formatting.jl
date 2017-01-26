module Format

import Base.show

export FormatSpec, FormatExpr, printfmt, printfmtln, format, generate_formatter
export pyfmt, cfmt, fmt
export fmt_default, fmt_default!, reset!, default_spec, default_spec!

# Deal with mess from #16058
@static if VERSION >= v"0.5.0"
    const ASCIIStr = String
    const UTF8Str = String
    const ByteStr = String
    const bytestr = String
else
    const ASCIIStr = ASCIIString
    const UTF8Str = UTF8String
    const ByteStr = ByteString
    const bytestr = bytestring
end

include("cformat.jl" )
include("fmtspec.jl")
include("fmtcore.jl")
include("formatexpr.jl")
include("fmt.jl")

end # module
