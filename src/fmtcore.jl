# core formatting functions

### auxiliary functions

function _repwrite(out::IO, c::Char, n::Int)
    while n > 0
        write(out, c)
        n -= 1
    end
end


### print string or char

function _pfmt_s(out::IO, fs::FormatSpec, s::Union(String,Char))
    wid = fs.width
    slen = length(s)
    if wid <= slen
        write(out, s)
    else
        a = fs.align
        if a == '<'
            write(out, s)
            _repwrite(out, fs.fill, wid-slen)
        else
            _repwrite(out, fs.fill, wid-slen)
            write(out, s)
        end
    end
end


### print integers

_mul(x::Integer, ::_Dec) = x * 10
_mul(x::Integer, ::_Bin) = x << 1
_mul(x::Integer, ::_Oct) = x << 3
_mul(x::Integer, ::Union(_Hex, _HEX)) = x << 4

_div(x::Integer, ::_Dec) = div(x, 10)
_div(x::Integer, ::_Bin) = x >> 1
_div(x::Integer, ::_Oct) = x >> 3
_div(x::Integer, ::Union(_Hex, _HEX)) = x >> 4

function _ndigits(x::Integer, op)  # suppose x is non-negative
    m = 1
    q = _div(x, op)
    while q > 0
        m += 1
        q = _div(q, op)
    end
    return m
end

_ipre(op) = ""
_ipre(::Union(_Hex, _HEX)) = "0x"
_ipre(::_Oct) = "0o"
_ipre(::_Bin) = "0b"

_digitchar(x::Integer, ::_Bin) = char(x == 0 ? '0' : '1')
_digitchar(x::Integer, ::_Dec) = char('0' + x)
_digitchar(x::Integer, ::_Oct) = char('0' + x)
_digitchar(x::Integer, ::_Hex) = char(x < 10 ? '0' + x : 'a' + (x - 10))
_digitchar(x::Integer, ::_HEX) = char(x < 10 ? '0' + x : 'A' + (x - 10))


function _pfmt_i{Op}(out::IO, fs::FormatSpec, x::Integer, op::Op)
    # calculate actual length
    ax = abs(x)
    xlen = _ndigits(abs(x), op)
    # sign char
    sch = x < 0 ? '-' :
          fs.sign == '+' ? '+' :
          fs.sign == ' ' ? ' ' : '\0'
    if sch != '\0'
        xlen += 1
    end
    # prefix (e.g. 0x, 0b, 0o)
    ip = ""
    if fs.ipre
        ip = _ipre(op)
        xlen += length(ip)
    end

    # printing
    wid = fs.width
    if wid <= xlen
        _pfmt_int(out, sch, ip, 0, ax, op)
    elseif fs.zpad
        _pfmt_int(out, sch, ip, wid-xlen, ax, op)
    else
        a = fs.align
        if a == '<'
            _pfmt_int(out, sch, ip, 0, ax, op)
            _repwrite(out, fs.fill, wid-xlen)
        else
            _repwrite(out, fs.fill, wid-xlen)
            _pfmt_int(out, sch, ip, 0, ax, op)
        end
    end
end

function _pfmt_int{Op}(out::IO, sch::Char, ip::ASCIIString, zs::Integer, ax::Integer, op::Op)
    # print sign
    if sch != '\0'
        write(out, sch)
    end
    # print prefix
    if !isempty(ip)
        write(out, ip)
    end
    # print padding zeros
    if zs > 0
        _repwrite(out, '0', zs)
    end
    # print actual digits
    if ax == 0
        write(out, '0')
    else
        _pfmt_intdigits(out, ax, op)
    end
end

function _pfmt_intdigits{Op,T<:Integer}(out::IO, ax::T, op::Op)
    b_lb = _div(ax, op)   
    b = one(T)
    while b <= b_lb
        b = _mul(b, op)
    end
    r = ax
    while b > 0
        (q, r) = divrem(r, b)
        write(out, _digitchar(q, op))
        b = _div(b, op)
    end
end


