formatters = Dict{ String, Function }()

sprintf1( fmt::String, x ) = eval(Expr(:call, generate_formatter( fmt ), x))

function checkfmt(fmt)
    @static if VERSION > v"1.6.0-DEV.854"
        test = Printf.Format(fmt)
        length(test.formats) == 1 ||
            error( "Only one AND undecorated format string is allowed")
    else
        test = @static VERSION >= v"1.4.0-DEV.180" ? Printf.parse(fmt) : Base.Printf.parse( fmt )
        (length( test ) == 1 && typeof( test[1] ) <: Tuple) ||
            error( "Only one AND undecorated format string is allowed")
    end
end

function generate_formatter( fmt::String )
    global formatters

    haskey( formatters, fmt ) && return formatters[fmt]

    if !occursin("'", fmt)
        checkfmt(fmt)
        formatter = @eval(x->@sprintf( $fmt, x ))
        return (formatters[ fmt ] = x->Base.invokelatest(formatter, x))
    end

    conversion = fmt[end]
    conversion in "sduifF" ||
        error( string("thousand separator not defined for ", conversion, " conversion") )

    fmtactual = replace( fmt, "'" => "", count=1 )
    checkfmt( fmtactual )
    if !occursin(conversion, "sfF")
        formatter = @eval(x->checkcommas(@sprintf( $fmtactual, x )))
        return (formatters[ fmt ] = x->Base.invokelatest(formatter, x))
    end

    formatter =
        if endswith( fmtactual, 's')
            @eval((x::Real)->((eltype(x) <: Rational)
                              ? addcommasrat(@sprintf( $fmtactual, x ))
                              : addcommasreal(@sprintf( $fmtactual, x ))))
        else
            @eval((x::Real)->addcommasreal(@sprintf( $fmtactual, x )))
        end
    return (formatters[ fmt ] = x->Base.invokelatest(formatter, x))
end

function addcommasreal(s)
    dpos = findfirst( isequal('.'), s )
    dpos !== nothing && return string(addcommas( s[1:dpos-1] ), s[ dpos:end ])
    # find the rightmost digit
    for i in length( s ):-1:1
        isdigit( s[i] ) && return string(addcommas( s[1:i] ), s[i+1:end])
    end
    s
end

function addcommasrat(s)
    # commas are added to only the numerator
    spos = findfirst( isequal('/'), s )
    string(addcommas( s[1:spos-1] ), s[spos:end])
end

function checkcommas(s)
    for i in length( s ):-1:1
        if isdigit( s[i] )
            s = string(addcommas( s[1:i] ), s[i+1:end])
            break
        end
    end
    s
end


function addcommas( s::String )
    len = length(s)
    t = ""
    for i in 1:3:len
        subs = s[max(1,len-i-1):len-i+1]
        if i == 1
            t = subs
        else
            if match( r"[0-9]", subs ) != nothing
                t = subs * "," * t
            else
                t = subs * t
            end
        end
    end
    return t
end

function generate_format_string(;
        width::Int=-1,
        precision::Int= -1,
        leftjustified::Bool=false,
        zeropadding::Bool=false,
        commas::Bool=false,
        signed::Bool=false,
        positivespace::Bool=false,
        alternative::Bool=false,
        conversion::String="f" #aAdecEfFiosxX
        )
    s = "%"
    if commas
        s *= "'"
    end
    if alternative && in( conversion[1], "aAeEfFoxX" )
        s *= "#"
    end
    if zeropadding && !leftjustified && width != -1
        s *= "0"
    end

    if signed
        s *= "+"
    elseif positivespace
        s *= " "
    end

    if width != -1
        if leftjustified
            s *= "-" * string( width )
        else
            s *= string( width )
        end
    end
    if precision != -1
        s *= "." * string( precision )
    end
    s * conversion
end

function format( x::T;
        width::Int=-1,
        precision::Int= -1,
        leftjustified::Bool=false,
        zeropadding::Bool=false, # when right-justified, use 0 instead of space to fill
        commas::Bool=false,
        signed::Bool=false, # +/- prefix
        positivespace::Bool=false,
        stripzeros::Bool=(precision== -1),
        parens::Bool=false, # use (1.00) instead of -1.00. Used in finance
        alternative::Bool=false, # usually for hex
        mixedfraction::Bool=false,
        mixedfractionsep::AbstractString="_",
        fractionsep::AbstractString="/", # num / den
        fractionwidth::Int = 0,
        tryden::Int = 0, # if 2 or higher, try to use this denominator, without losing precision
        suffix::AbstractString="", # useful for units/%
        autoscale::Symbol=:none, # :metric, :binary or :finance
        conversion::String=""
        ) where {T<:Real}
    checkwidth = commas
    if conversion == ""
        if T <: AbstractFloat || T <: Rational && precision != -1
            actualconv = "f"
        elseif T <: Unsigned
            actualconv = "x"
        elseif T <: Integer
            actualconv = "d"
        else
            conversion = "s"
            actualconv = "s"
        end
    else
        actualconv = conversion
    end
    if signed && commas
        error( "You cannot use signed (+/-) AND commas at the same time")
    end
    if T <: Rational && conversion == "s"
        stripzeros = false
    end
    if ( T <: AbstractFloat && actualconv == "f" || T <: Integer ) && autoscale != :none
        actualconv = "f"
        if autoscale == :metric
            scales = [
                (1e24, "Y" ),
                (1e21, "Z" ),
                (1e18, "E" ),
                (1e15, "P" ),
                (1e12, "T" ),
                (1e9,  "G"),
                (1e6,  "M"),
                (1e3,  "k") ]
            if abs(x) > 1
                for (mag, sym) in scales
                    if abs(x) >= mag
                        x /= mag
                        suffix = sym * suffix
                        break
                    end
                end
            elseif T <: AbstractFloat
                smallscales = [
                    ( 1e-12, "p" ),
                    ( 1e-9,  "n" ),
                    ( 1e-6,  "μ" ),
                    ( 1e-3,  "m" ) ]
                for (mag,sym) in smallscales
                    if abs(x) < mag*10
                        x /= mag
                        suffix = sym * suffix
                        break
                    end
                end
            end
        else
            if autoscale == :binary
                scales = [
                    (1024.0 ^8,  "Yi" ),
                    (1024.0 ^7,  "Zi" ),
                    (1024.0 ^6,  "Ei" ),
                    (1024.0 ^5,  "Pi" ),
                    (1024.0 ^4,  "Ti" ),
                    (1024.0 ^3,  "Gi"),
                    (1024.0 ^2,  "Mi"),
                    (1024.0,     "Ki")
                ]
            else # :finance
                scales = [
                    (1e12, "t" ),
                    (1e9,  "b"),
                    (1e6,  "m"),
                    (1e3,  "k") ]
            end
            for (mag, sym) in scales
                if abs(x) >= mag
                    x /= mag
                    suffix = sym * suffix
                    break
                end
            end
        end
    end

    nonneg = x >= 0
    fractional = 0
    if T <: Rational && mixedfraction
        actualconv = "d"
        actualx = trunc( Int, x )
        fractional = abs(x) - abs(actualx)
    else
        if parens && !in( actualconv[1], "xX" )
            actualx = abs(x)
        else
            actualx = x
        end
    end
    s = sprintf1( generate_format_string( width=width,
        precision=precision,
        leftjustified=leftjustified,
        zeropadding=zeropadding,
        commas=commas,
        signed=signed,
        positivespace=positivespace,
        alternative=alternative,
        conversion=actualconv
    ),actualx)

    if T <:Rational && conversion == "s"
        if mixedfraction && fractional != 0
            num = fractional.num
            den = fractional.den
            if tryden >= 2 && mod( tryden, den ) == 0
                num *= div(tryden,den)
                den = tryden
            end
            fs = string( num ) * fractionsep * string(den)
            if length(fs) < fractionwidth
                fs = repeat( "0", fractionwidth - length(fs) ) * fs
            end
            s = rstrip(s)
            if actualx != 0
                s = rstrip(s) * mixedfractionsep * fs
            else
                if !nonneg
                    s = "-" * fs
                else
                    s = fs
                end
            end
            checkwidth = true
        elseif !mixedfraction
            s = replace( s, "//" => fractionsep )
            checkwidth = true
        end
    elseif stripzeros && in( actualconv[1], "fFeEs" )
        dpos = findfirst( isequal('.'), s )
        if in( actualconv[1], "eEs" )
            if in( actualconv[1], "es" )
                epos = findfirst( isequal('e'), s )
            else
                epos = findfirst( isequal('E'), s )
            end
            if epos === nothing
                rpos = length( s )
            else
                rpos = epos-1
            end
        else
            rpos = length(s)
        end
        # rpos at this point is the rightmost possible char to start
        # stripping
        stripfrom = rpos+1
        for i = rpos:-1:dpos+1
            if s[i] == '0'
                stripfrom = i
            elseif s[i] ==' '
                continue
            else
                break
            end
        end
        if stripfrom <= rpos
            if stripfrom == dpos+1 # everything after decimal is 0, so strip the decimal too
                stripfrom = dpos
            end
            s = s[1:stripfrom-1] * s[rpos+1:end]
            checkwidth = true
        end
    end

    s *= suffix

    if parens && !in( actualconv[1], "xX" )
        # if zero or positive, we still need 1 white space on the right
        if nonneg
            s = " " * strip(s) * " "
        else
            s = "(" * strip(s) * ")"
        end

        checkwidth = true
    end

    if checkwidth && width != -1
        if length(s) > width
            s = replace( s, " " => "", count=length(s)-width )
            if length(s) > width && endswith( s, " " )
                s = reverse( replace( reverse(s), " " => "", count=length(s)-width ) )
            end
            if length(s) > width
                s = replace( s, "," => "", count=length(s)-width )
            end
        elseif length(s) < width
            if leftjustified
                s = s * repeat( " ", width - length(s) )
            else
                s = repeat( " ", width - length(s) ) * s
            end
        end
    end

    s
end
