
type DefaultSpec
  typechar::Char
  fspec::FormatSpec
  DefaultSpec(c::Char) = new(c, FormatSpec(c))
end

# global defaults
const DEFAULT_FORMATTER_I = DefaultSpec('d')
const DEFAULT_FORMATTER_F = DefaultSpec('f')
const DEFAULT_FORMATTER_C = DefaultSpec('c')
const DEFAULT_FORMATTER_S = DefaultSpec('s')

# get the default spec for this type
defaultSpec{T<:Integer}(::Type{T})       = DEFAULT_FORMATTER_I
defaultSpec{T<:FloatingPoint}(::Type{T}) = DEFAULT_FORMATTER_F
defaultSpec{T<:Char}(::Type{T})          = DEFAULT_FORMATTER_C
defaultSpec{T<:String}(::Type{T})        = DEFAULT_FORMATTER_S
defaultSpec(x) = defaultSpec(typeof(x))

spec{T}(::Type{T}) = defaultSpec(T).fspec
spec(x) = defaultSpec(x).fspec


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


reset!{T}(::Type{T}) = (dspec = defaultSpec(T); dspec.fspec = FormatSpec(dspec.c); nothing)


# update the default for a specific type
function default!{T}(::Type{T}, syms::Symbol...; kwargs...)
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
    default!(T; d...)
  end
  nothing
end

# update the default for all types
function default!(syms::Symbol...; kwargs...)
  if isempty(syms)
    default!(Integer; kwargs...)
    default!(FloatingPoint; kwargs...)
    default!(Char; kwargs...)
    default!(String; kwargs...)
  else
    d = addKWArgsFromSymbols(kwargs, syms...)
    default!(; d...)
  end
  nothing
end




# TODO: do more caching to optimize repeated calls

# creates a new FormatSpec by overriding the defaults and passes it to cfmt
fmt(x; kwargs...) = cfmt(isempty(kwargs) ? spec(x) : FormatSpec(spec(x); kwargs...), x)


# some helper method calls
fmt(x, prec::Int, args...; kwargs...) = fmt(x, args...; prec=prec, kwargs...)
fmt(x, prec::Int, width::Int, args...; kwargs...) = fmt(x, args...; prec=prec, width=width, kwargs...)

# integrate some symbol shorthands into the keyword args
function fmt(x, syms::Symbol...; kwargs...)
  d = addKWArgsFromSymbols(kwargs, syms...)
  fmt(x; d...)
end
