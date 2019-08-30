using Formatting
using Test
using Printf
using Random

_erfinv(z) = sqrt(π) * Base.Math.@horner(z, 0, 1, 0, π/12, 0, 7π^2/480, 0, 127π^3/40320, 0,
                                         4369π^4/5806080, 0, 34807π^5/182476800) / 2

function test_equality()
    println( "test cformat equality...")
    Random.seed!( 10 )
    fmts = [ (x->@sprintf("%10.4f",x), "%10.4f"),
             (x->@sprintf("%f", x),    "%f"),
             (x->@sprintf("%e", x),    "%e"),
             (x->@sprintf("%10f", x),  "%10f"),
             (x->@sprintf("%.3f", x),  "%.3f"),
             (x->@sprintf("%.3e", x),  "%.3e")]
    for (mfmtr,fmt) in fmts
        for i in 1:10000
            n = _erfinv( rand() * 1.99 - 1.99/2.0 )
            expect = mfmtr( n )
            actual = sprintf1( fmt, n )
            @test expect == actual
        end
    end

    fmts = [ (x->@sprintf("%d",x),    "%d"),
             (x->@sprintf("%10d",x),  "%10d"),
             (x->@sprintf("%010d",x), "%010d"),
             (x->@sprintf("%-10d",x), "%-10d")]
    for (mfmtr,fmt) in fmts
        for i in 1:10000
            j = round(Int, _erfinv( rand() * 1.99 - 1.99/2.0 ) * 100000 )
            expect = mfmtr( j )
            actual = sprintf1( fmt, j )
            @test expect == actual
        end
    end
    println( "...Done" )
end

@time test_equality()

println( "\nTest speed" )

function native_int()
    for i in 1:200000
        @sprintf( "%10d", i )
    end
end
function runtime_int()
    for i in 1:200000
        sprintf1( "%10d", i )
    end
end
function runtime_int_bypass()
    f = generate_formatter( "%10d" )
    for i in 1:200000
        f( i )
    end
end

println( "integer @sprintf speed")
@time native_int()
println( "integer sprintf speed")
@time runtime_int()
println( "integer sprintf speed, bypass repeated lookup")
@time runtime_int_bypass()

function native_float()
    Random.seed!( 10 )
    for i in 1:200000
        @sprintf( "%10.4f", _erfinv( rand() ) )
    end
end
function runtime_float()
    Random.seed!( 10 )
    for i in 1:200000
        sprintf1( "%10.4f", _erfinv( rand() ) )
    end
end
function runtime_float_bypass()
    f = generate_formatter( "%10.4f" )
    Random.seed!( 10 )
    for i in 1:200000
        f( _erfinv( rand() ) )
    end
end

println()
println( "float64 @sprintf speed")
@time native_float()
println( "float64 sprintf speed")
@time runtime_float()
println( "float64 sprintf speed, bypass repeated lookup")
@time runtime_float_bypass()

function test_commas()
    println( "\ntest commas..." )
    @test sprintf1( "%'d", 1000 ) == "1,000"
    @test sprintf1( "%'d", -1000 ) == "-1,000"
    @test sprintf1( "%'d", 100 ) == "100"
    @test sprintf1( "%'d", -100 ) == "-100"
    @test sprintf1( "%'f", Inf ) == "Inf"
    @test sprintf1( "%'f", -Inf ) == "-Inf"
    @test sprintf1( "%'s", 1000.0 ) == "1,000.0"
    @test sprintf1( "%'s", 1234567.0 ) == "1.234567e6"
end

function test_format()
    println( "test format...")
    @test format( 10 ) == "10"
    @test format( 10.0 ) == "10"
    @test format( 10.0, precision=2 ) == "10.00"
    @test format( 111//100, precision=2 ) == "1.11"
    @test format( 111//100 ) == "111/100"
    @test format( 1234, commas=true ) == "1,234"
    @test format( 1234, conversion="f", precision=2 ) == "1234.00"
    @test format( 1.23, precision=3 ) == "1.230"
    @test format( 1.23, precision=3, stripzeros=true ) == "1.23"
    @test format( 1.00, precision=3, stripzeros=true ) == "1"

    @test format( 1.0, conversion="e", stripzeros=true ) == "1e+00"
    @test format( 1.0, conversion="e", precision=4 ) == "1.0000e+00"

    # hex output
    @test format( 1118, conversion="x" ) == "45e"
    @test format( 1118, width=4, conversion="x" ) == " 45e"
    @test format( 1118, width=4, zeropadding=true, conversion="x" ) == "045e"
    @test format( 1118, alternative=true, conversion="x" ) == "0x45e"
    @test format( 1118, width=4, alternative=true, conversion="x" ) == "0x45e"
    @test format( 1118, width=6, alternative=true, conversion="x", zeropadding=true ) == "0x045e"

    # mixed fractions
    @test format( 3//2, mixedfraction=true ) == "1_1/2"
    @test format( -3//2, mixedfraction=true ) == "-1_1/2"
    @test format( 3//100, mixedfraction=true ) == "3/100"
    @test format( -3//100, mixedfraction=true ) == "-3/100"
    @test format( 307//100, mixedfraction=true ) == "3_7/100"
    @test format( -307//100, mixedfraction=true ) == "-3_7/100"
    @test format( 307//100, mixedfraction=true, fractionwidth=6 ) == "3_07/100"
    @test format( -307//100, mixedfraction=true, fractionwidth=6 ) == "-3_07/100"
    @test format( -302//100, mixedfraction=true ) == "-3_1/50"
    # try to make the denominator 100
    @test format( -302//100, mixedfraction=true,tryden = 100 ) == "-3_2/100"
    @test format( -302//30, mixedfraction=true,tryden = 100 ) == "-10_1/15" # lose precision otherwise
    @test format( -302//100, mixedfraction=true,tryden = 100,fractionwidth=6 ) == "-3_02/100" # lose precision otherwise

    #commas
    @test format( 12345678, width=10, commas=true ) == "12,345,678"
    # it would try to squeeze out the commas
    @test format( 12345678, width=9, commas=true ) == "12345,678"
    # until it can't anymore
    @test format( 12345678, width=8, commas=true ) == "12345678"
    @test format( 12345678, width=7, commas=true ) == "12345678"

    # only the numerator would have commas
    @test format( 1111//1000, commas=true ) == "1,111/1000"

    # this shows how, with enough space, parens line up with empty spaces
    @test format(  12345678, width=12, commas=true, parens=true )== " 12,345,678 "
    @test format( -12345678, width=12, commas=true, parens=true )== "(12,345,678)"
    # same with unspecified width
    @test format(  12345678, commas=true, parens=true )== " 12,345,678 "
    @test format( -12345678, commas=true, parens=true )== "(12,345,678)"

    @test format( 1.2e9, autoscale = :metric ) == "1.2G"
    @test format( 1.2e6, autoscale = :metric ) == "1.2M"
    @test format( 1.2e3, autoscale = :metric ) == "1.2k"
    @test format( 1.2e-6, autoscale = :metric ) == "1.2μ"
    @test format( 1.2e-9, autoscale = :metric ) == "1.2n"
    @test format( 1.2e-12, autoscale = :metric ) == "1.2p"

    @test format( 1.2e9, autoscale = :finance ) == "1.2b"
    @test format( 1.2e6, autoscale = :finance ) == "1.2m"
    @test format( 1.2e3, autoscale = :finance ) == "1.2k"

    @test format( 0x40000000, autoscale = :binary ) == "1Gi"
    @test format( 0x100000, autoscale = :binary ) == "1Mi"
    @test format( 0x800, autoscale = :binary ) == "2Ki"
    @test format( 0x400, autoscale = :binary ) == "1Ki"

    @test format( 100.00, precision=2, suffix="%" ) == "100.00%"
    @test format( 100, precision=2, suffix="%" ) == "100%"
    @test format( 100, precision=2, suffix="%", conversion="f" ) == "100.00%"
end

test_commas()
test_format()

function test_generate_formatter()
    fmt = generate_formatter( "%7.2f" )
    @test fmt( 1.234 ) == "   1.23"
    @test fmt( π ) == "   3.14"
    fmt = generate_formatter( "%'10.2f" )
    @test fmt( 1234.5678 ) == "   1,234.57"    # BUG 1 extra space
    fmt = generate_formatter( "%'10d" )
    @test fmt( 1234567 ) == "   1,234,567"    # BUG 2 extra spaces
end

test_generate_formatter()
