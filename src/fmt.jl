
# interface proposal by Tom Breloff (@tbreloff)... comments welcome
# This uses the more basic formatting based on FormatSpec and the cfmt method (formerly called fmt, which I repurposed)

# TODO: swap out FormatSpec for something that is able to use the "format" method, which has more options for units, prefixes, etc
# TODO: support rational numbers, autoscale, etc as in "format"

# --------------------------------------------------------------------------------------------------

# the DefaultSpec object is just something to hold onto the current FormatSpec.
# we keep the typechar around specically for the reset! function, to go back to the starting state

type DefaultSpec
  typechar::Char
  fspec::FormatSpec
  DefaultSpec(c::Char) = new(c, FormatSpec(c))
end

const DEFAULT_FORMATTERS = Dict{DataType, DefaultSpec}()

# adds a new default formatter for this type
defaultSpec!{T}(::Type{T}, c::Char) = (DEFAULT_FORMATTERS[T] = DefaultSpec(c); nothing)

# note: types T and K will now both share K's default
defaultSpec!{T,K}(::Type{T}, ::Type{K}) = (DEFAULT_FORMATTERS[T] = DEFAULT_FORMATTERS[K]; nothing)

# seed it with some basic default formatters
for (t, c) in [(Integer,'d'), (FloatingPoint,'f'), (Char,'c'), (String,'s')]
  defaultSpec!(t, c)
end

reset!{T}(::Type{T}) = (dspec = defaultSpec(T); dspec.fspec = FormatSpec(dspec.typechar); nothing)


# --------------------------------------------------------------------------------------------------


function addKWArgsFromSymbols(kwargs, syms::Symbol...)
  d = Dict(kwargs)
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
# note: if you want to set a default for an abstract type (i.e. FloatingPoint) you'll need to extend this method like here:
defaultSpec{T<:Integer}(::Type{T}) = DEFAULT_FORMATTERS[Integer]
defaultSpec{T<:FloatingPoint}(::Type{T}) = DEFAULT_FORMATTERS[FloatingPoint]
defaultSpec{T<:String}(::Type{T}) = DEFAULT_FORMATTERS[String]
function defaultSpec{T}(::Type{T})
  get(DEFAULT_FORMATTERS, T) do
    error("Missing default spec for type $T... call default!(T, c): $DEFAULT_FORMATTERS")
  end
end
defaultSpec(x) = defaultSpec(typeof(x))

fmt_default{T}(::Type{T}) = defaultSpec(T).fspec
fmt_default(x) = defaultSpec(x).fspec



# first resets the fmt_default spec to the given arg, then continue by updating with args and kwargs
fmt_default!{T}(::Type{T}, c::Char, args...; kwargs...) = (defaultSpec!(T,c); fmt_default!(T, args...; kwargs...))
fmt_default!{T,K}(::Type{T}, ::Type{K}, args...; kwargs...) = (defaultSpec!(T,K); fmt_default!(T, args...; kwargs...))

# update the fmt_default for a specific type
function fmt_default!{T}(::Type{T}, syms::Symbol...; kwargs...)
  if isempty(syms)

    # if there are no arguments, reset to initial defaults
    if isempty(kwargs)
      reset!(T)
      return
    end

    # otherwise update the spec
    dspec = defaultSpec(T)
    dspec.fspec = FormatSpec(dspec.fspec; kwargs...)

  else
    d = addKWArgsFromSymbols(kwargs, syms...)
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
    d = addKWArgsFromSymbols(kwargs, syms...)
    fmt_default!(; d...)
  end
  nothing
end


# --------------------------------------------------------------------------------------------------

# TODO: get rid of this entire hack by moving commas into cfmt

function optionalCommas(x::Real, s::String, fspec::FormatSpec)
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
optionalCommas(x, s::String, fspec::FormatSpec) = s

# --------------------------------------------------------------------------------------------------


# TODO: do more caching to optimize repeated calls

# creates a new FormatSpec by overriding the defaults and passes it to cfmt
# note: adding kwargs is only appropriate for one-off formatting.  
#       normally it will be much faster to change the fmt_default formatting as needed
function fmt(x; kwargs...)
  fspec = isempty(kwargs) ? fmt_default(x) : FormatSpec(fmt_default(x); kwargs...)
  s = cfmt(fspec, x)

  # add the commas now... I was confused as to when this is done currently
  if fspec.tsep
    return optionalCommas(x, s, fspec)
  end
  s
end

# some helper method calls, which just convert to kwargs
fmt(x, prec::Int, args...; kwargs...) = fmt(x, args...; prec=prec, kwargs...)
fmt(x, prec::Int, width::Int, args...; kwargs...) = fmt(x, args...; prec=prec, width=width, kwargs...)

# integrate some symbol shorthands into the keyword args
# note: as above, this will generate relavent kwargs, so to format in a tight loop, you should probably update the fmt_default
function fmt(x, syms::Symbol...; kwargs...)
  d = addKWArgsFromSymbols(kwargs, syms...)
  fmt(x; d...)
end
