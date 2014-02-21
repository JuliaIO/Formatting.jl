# formatting expression

### Format entry

immutable FormatEntry
    iarg::Int
    spec::FormatSpec

    FormatEntry(ia::Int, spec::FormatSpec) = new(ia, spec)
    FormatEntry(ia::Int, spec::String) = new(ia, FormatSpec(spec))
end

function FormatEntry(s::String)
    @assert s[1] == '{' && s[end] == '}'
    sc = s[2:end-1]
    icolon = search(sc, ':')
    if icolon == 0
        iarg = int(sc)
        spec = FormatSpec('s')
    else
        if icolon < 2
            error("Argument index is needed.")
        end
        iarg = int(sc[1:icolon-1])
        spec = FormatSpec(sc[icolon+1:end])
    end
    return FormatEntry(iarg, spec)
end


### Format expression

type FormatExpr
    prefix::UTF8String
    suffix::UTF8String
    entries::Vector{FormatEntry}
    inter::Vector{UTF8String}
end

function FormatExpr(s::String)
    slen = length(s)
    
    # init
    prefix = utf8("")
    suffix = utf8("")
    entries = FormatEntry[]
    inter = UTF8String[]

    # scan
    p = search(s, '{')
    if p > 0
        prefix = utf8(s[1:p-1])
        q = search(s, '}', p+1)
        q > p || error("Unmatched { in format expression.")
        push!(entries, FormatEntry(s[p:q]))
        p = search(s, '{', q+1)
        while p > 0
            push!(inter, utf8(s[q+1:p-1]))
            q = search(s, '}', p+1)
            q > p || error("Unmatched { in format expression.")
            push!(entries, FormatEntry(s[p:q]))
            p = search(s, '{', q+1)
        end
        suffix = utf8(s[q+1:end])
    else
        prefix = s
    end
    FormatExpr(prefix, suffix, entries, inter)
end

function printfmt(io::IO, fe::FormatExpr, args...)
    if !isempty(fe.prefix)
        write(io, fe.prefix)
    end
    ents = fe.entries
    ne = length(ents)
    if ne > 0
        e = ents[1]
        printfmt(io, e.spec, args[e.iarg])
        for i = 2:ne
            write(io, fe.inter[i-1])
            e = ents[i]
            printfmt(io, e.spec, args[e.iarg])
        end
    end
    if !isempty(fe.suffix)
        write(io, fe.suffix)
    end
end

printfmt(io::IO, fe::String, args...) = printfmt(io, FormatExpr(fe), args...)
printfmt(fe::Union(String,FormatExpr), args...) = printfmt(STDOUT, fe, args...)

printfmtln(io::IO, fe::Union(String,FormatExpr), args...) = (printfmt(io, fe, args...); println(io))
printfmtln(fe::Union(String,FormatExpr), args...) = printfmtln(STDOUT, fe, args...)

format(fe::Union(String,FormatExpr), args...) = 
    (buf = IOBuffer(); printfmt(buf, fe, args...); bytestring(buf))

