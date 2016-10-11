# interface proposal by Tom Breloff (@tbreloff)... comments welcome
# This uses the more basic formatting based on FormatSpec and the pyfmt method
# (formerly called fmt, which I repurposed)

# TODO: swap out FormatSpec for something that is able to use the "format" method,
# which has more options for units, prefixes, etc
# TODO: support rational numbers, autoscale, etc as in "format"

# --------------------------------------------------------------------------------------------------

# the DefaultSpec object is just something to hold onto the current FormatSpec.
# we keep the typechar around specifically for the reset! function,
# to go back to the starting state

type DefaultSpec
    typechar::Char
    fspec::FormatSpec
    DefaultSpec(c::Char) = new(c, FormatSpec(c))
end

const DEFAULT_FORMATTERS = Dict{DataType, DefaultSpec}()

# adds a new default formatter for this type
default_spec!{T}(::Type{T}, c::Char) = (DEFAULT_FORMATTERS[T] = DefaultSpec(c); nothing)

# note: types T and K will now both share K's default
default_spec!{T,K}(::Type{T}, ::Type{K}) = (DEFAULT_FORMATTERS[T] = DEFAULT_FORMATTERS[K]; nothing)

# seed it with some basic default formatters
for (t, c) in [(Integer,'d'), (AbstractFloat,'f'), (Char,'c'), (AbstractString,'s')]
    default_spec!(t, c)
end

reset!{T}(::Type{T}) = (dspec = default_spec(T); dspec.fspec = FormatSpec(dspec.typechar); nothing)


# --------------------------------------------------------------------------------------------------


function _add_kwargs_from_symbols(kwargs, syms::Symbol...)
    d = Dict{Symbol, Any}(kwargs)
    for s in syms
        if s == :ljust || s == :left
            d[:align] = '<'
        elseif s == :rjust || s == :right
            d[:align] = '>'
        elseif s == :commas
            d[:tsep] = true
        elseif s == :zpad || s == :zeropad
            d[:zpad] = true
        elseif s == :ipre || s == :prefix
            d[:ipre] = true
        end
    end
    d
end

# --------------------------------------------------------------------------------------------------

# methods to get the current default objects
# note: if you want to set a default for an abstract type (i.e. AbstractFloat)
# you'll need to extend this method like here:
default_spec{T<:Integer}(::Type{T}) = DEFAULT_FORMATTERS[Integer]
default_spec{T<:AbstractFloat}(::Type{T}) = DEFAULT_FORMATTERS[AbstractFloat]
default_spec{T<:AbstractString}(::Type{T}) = DEFAULT_FORMATTERS[AbstractString]
function default_spec{T}(::Type{T})
    get(DEFAULT_FORMATTERS, T) do
        error("Missing default spec for type $T... call default!(T, c): $DEFAULT_FORMATTERS")
    end
end
default_spec(x) = default_spec(typeof(x))

fmt_default{T}(::Type{T}) = default_spec(T).fspec
fmt_default(x) = default_spec(x).fspec



# first resets the fmt_default spec to the given arg,
# then continue by updating with args and kwargs
fmt_default!{T}(::Type{T}, c::Char, args...; kwargs...) =
    (default_spec!(T,c); fmt_default!(T, args...; kwargs...))
fmt_default!{T,K}(::Type{T}, ::Type{K}, args...; kwargs...) =
    (default_spec!(T,K); fmt_default!(T, args...; kwargs...))

# update the fmt_default for a specific type
function fmt_default!{T}(::Type{T}, syms::Symbol...; kwargs...)
    if isempty(syms)

        # if there are no arguments, reset to initial defaults
        if isempty(kwargs)
            reset!(T)
            return
        end

        # otherwise update the spec
        dspec = default_spec(T)
        dspec.fspec = FormatSpec(dspec.fspec; kwargs...)

    else
        d = _add_kwargs_from_symbols(kwargs, syms...)
        fmt_default!(T; d...)
    end
    nothing
end

# update the fmt_default for all types
function fmt_default!(syms::Symbol...; kwargs...)
    if isempty(syms)
        for k in keys(DEFAULT_FORMATTERS)
            fmt_default!(k; kwargs...)
        end
    else
        d = _add_kwargs_from_symbols(kwargs, syms...)
        fmt_default!(; d...)
    end
    nothing
end

# --------------------------------------------------------------------------------------------------

# TODO: get rid of this entire hack by moving commas into pyfmt

function _optional_commas(x::Real, s::AbstractString, fspec::FormatSpec)
    dpos = findfirst(s, '.')
    prevwidth = length(s)

    if dpos == 0
        s = addcommas(s)
    else
        s = string(addcommas(s[1:dpos-1]), '.', s[dpos+1:end])
    end

    # check for excess width from commas
    w = length(s)
    if fspec.width > 0 && w > fspec.width && w > prevwidth
        # we may have made the string too wide with those commas... gotta fix it
        s = strip(s)
        n = fspec.width - length(s)
        if fspec.align == '<' # left alignment
            s = string(s, " "^n)
        else
            s = string(" "^n, s)
        end 
    end

    s
end
_optional_commas(x, s::AbstractString, fspec::FormatSpec) = s

# --------------------------------------------------------------------------------------------------

"""
Creates a new FormatSpec by overriding the defaults and passes it to pyfmt

Optionally width and precision can be passed positionally, after the value to be formatted.

Some keyword arguments can be passed simply as symbols:
```
Symbol            | Meaning
------------------|------------------------------------------
:ljust or :left   | Left justified, same as < for FormatSpec
:rjust or :right  | Right justified, same as > for FormatSpec
:zpad or :zeropad | Pad with 0s on left
:ipre or :prefix  | Whether to prefix 0b, 0o, or 0x
:commas           | Add commas every 3 digits
```

Also, keyword arguments can be given:
```
Keyword | Type | Meaning                   | Default
--------|------|---------------------------|-------
fill    | Char | Fill character            | ' '
align   | Char | Alignment character       | '\\0'
sign    | Char | Sign character            | '-'
width   | Int  | Field width               | -1, i.e. ignored
prec    | Int  | Floating Precision        | -1, i.e. ignored
ipre    | Bool | Use 0b, 0o, or 0x prefix? | false
zpad    | Bool | Pad with 0s on left       | false
tsep    | Bool | Use thousands separator?  | false
```
"""
function fmt end

# TODO: do more caching to optimize repeated calls

# creates a new FormatSpec by overriding the defaults and passes it to pyfmt
# note: adding kwargs is only appropriate for one-off formatting.  
#       normally it will be much faster to change the fmt_default formatting as needed
function fmt(x; kwargs...)
    fspec = fmt_default(x)
    isempty(kwargs) || (fspec = FormatSpec(fspec; kwargs...))
    s = pyfmt(fspec, x)
    # add the commas now... I was confused as to when this is done currently
    fspec.tsep ? _optional_commas(x, s, fspec) : s
end

# some helper method calls, which just convert to kwargs
fmt(x, width::Int, args...; kwargs...) = fmt(x, args...; width=width, kwargs...)

fmt(x, width::Int, prec::Int, args...; kwargs...) =
    fmt(x, args...; width=width, prec=prec, kwargs...)

# integrate some symbol shorthands into the keyword args
# note: as above, this will generate relevant kwargs, so to format in a tight loop,
# you should probably update the fmt_default

function fmt(x, syms::Symbol...; kwargs...)
    d = _add_kwargs_from_symbols(kwargs, syms...)
    fmt(x; d...)
end
