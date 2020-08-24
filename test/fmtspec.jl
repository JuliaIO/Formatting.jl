# test format spec parsing

using Formatting
using Test


# default spec
fs = FormatSpec("")
@test fs.typ == 's'
@test fs.fill == ' '
@test fs.align == '<'
@test fs.sign == '-'
@test fs.width == -1
@test fs.prec == -1
@test fs.ipre == false
@test fs.zpad == false
@test fs.tsep == false

# more cases

fs = FormatSpec("d")
@test fs == FormatSpec('d')
@test fs.align == '>'

@test FormatSpec("8x") == FormatSpec('x'; width=8)
@test FormatSpec("08b") == FormatSpec('b'; width=8, zpad=true)
@test FormatSpec("12f") == FormatSpec('f'; width=12, prec=6)
@test FormatSpec("12.7f") == FormatSpec('f'; width=12, prec=7)
@test FormatSpec("+08o") == FormatSpec('o'; width=8, zpad=true, sign='+')

@test FormatSpec("8") == FormatSpec('s'; width=8)
@test FormatSpec(".6f") == FormatSpec('f'; prec=6)
@test FormatSpec("<8d") == FormatSpec('d'; width=8, align='<')
@test FormatSpec("#<8d") == FormatSpec('d'; width=8, fill='#', align='<')
@test FormatSpec("⋆<8d") == FormatSpec('d'; width=8, fill='⋆', align='<')
@test FormatSpec("#8,d") == FormatSpec('d'; width=8, ipre=true, tsep=true)

# format string

@test fmt("", "abc") == "abc"
@test fmt("", "αβγ") == "αβγ"
@test fmt("s", "abc") == "abc"
@test fmt("s", "αβγ") == "αβγ"
@test fmt("2s", "abc") == "abc"
@test fmt("2s", "αβγ") == "αβγ"
@test fmt("5s", "abc") == "abc  "
@test fmt("5s", "αβγ") == "αβγ  "
@test fmt(">5s", "abc") == "  abc"
@test fmt(">5s", "αβγ") == "  αβγ"
@test fmt("*>5s", "abc") == "**abc"
@test fmt("⋆>5s", "αβγ") == "⋆⋆αβγ"
@test fmt("*<5s", "abc") == "abc**"
@test fmt("⋆<5s", "αβγ") == "αβγ⋆⋆"

# format char

@test fmt("", 'c') == "c"
@test fmt("", 'γ') == "γ"
@test fmt("c", 'c') == "c"
@test fmt("c", 'γ') == "γ"
@test fmt("3c", 'c') == "c  "
@test fmt("3c", 'γ') == "γ  "
@test fmt(">3c", 'c') == "  c"
@test fmt(">3c", 'γ') == "  γ"
@test fmt("*>3c", 'c') == "**c"
@test fmt("⋆>3c", 'γ') == "⋆⋆γ"
@test fmt("*<3c", 'c') == "c**"
@test fmt("⋆<3c", 'γ') == "γ⋆⋆"

# format integer

@test fmt("", 1234) == "1234"
@test fmt("d", 1234) == "1234"
@test fmt("n", 1234) == "1234"
@test fmt("x", 0x2ab) == "2ab"
@test fmt("X", 0x2ab) == "2AB"
@test fmt("o", 0o123) == "123"
@test fmt("b", 0b1101) == "1101"

@test fmt("d", 0) == "0"
@test fmt("d", 9) == "9"
@test fmt("d", 10) == "10"
@test fmt("d", 99) == "99"
@test fmt("d", 100) == "100"
@test fmt("d", 1000) == "1000"

@test fmt("06d", 123) == "000123"
@test fmt("+6d", 123) == "  +123"
@test fmt("+06d", 123) == "+00123"
@test fmt(" d", 123) == " 123"
@test fmt(" 6d", 123) == "   123"
@test fmt("<6d", 123) == "123   "
@test fmt(">6d", 123) == "   123"
@test fmt("*<6d", 123) == "123***"
@test fmt("⋆<6d", 123) == "123⋆⋆⋆"
@test fmt("*>6d", 123) == "***123"
@test fmt("⋆>6d", 123) == "⋆⋆⋆123"
@test fmt("< 6d", 123) == " 123  "
@test fmt("<+6d", 123) == "+123  "
@test fmt("> 6d", 123) == "   123"
@test fmt(">+6d", 123) == "  +123"

@test fmt("+d", -123) == "-123"
@test fmt("-d", -123) == "-123"
@test fmt(" d", -123) == "-123"
@test fmt("06d", -123) == "-00123"
@test fmt("<6d", -123) == "-123  "
@test fmt(">6d", -123) == "  -123"

# format floating point (f)

@test fmt("", 0.125) == "0.125"
@test fmt("f", 0.0) == "0.000000"
@test fmt("f", -0.0) == "-0.000000"
@test fmt("f", 0.001) == "0.001000"
@test fmt("f", 0.125) == "0.125000"
@test fmt("f", 1.0/3) == "0.333333"
@test fmt("f", 1.0/6) == "0.166667"
@test fmt("f", -0.125) == "-0.125000"
@test fmt("f", -1.0/3) == "-0.333333"
@test fmt("f", -1.0/6) == "-0.166667"
@test fmt("f", 1234.5678) == "1234.567800"
@test fmt("8f", 1234.5678) == "1234.567800"

@test fmt("8.2f", 8.376) == "    8.38"
@test fmt("<8.2f", 8.376) == "8.38    "
@test fmt(">8.2f", 8.376) == "    8.38"
@test fmt("8.2f", -8.376) == "   -8.38"
@test fmt("<8.2f", -8.376) == "-8.38   "
@test fmt(">8.2f", -8.376) == "   -8.38"

@test fmt("<08.2f", 8.376) == "00008.38"
@test fmt(">08.2f", 8.376) == "00008.38"
@test fmt("<08.2f", -8.376) == "-0008.38"
@test fmt(">08.2f", -8.376) == "-0008.38"
@test fmt("*<8.2f", 8.376) == "8.38****"
@test fmt("⋆<8.2f", 8.376) == "8.38⋆⋆⋆⋆"
@test fmt("*>8.2f", 8.376) == "****8.38"
@test fmt("⋆>8.2f", 8.376) == "⋆⋆⋆⋆8.38"
@test fmt("*<8.2f", -8.376) == "-8.38***"
@test fmt("⋆<8.2f", -8.376) == "-8.38⋆⋆⋆"
@test fmt("*>8.2f", -8.376) == "***-8.38"
@test fmt("⋆>8.2f", -8.376) == "⋆⋆⋆-8.38"

@test fmt(".2f", 0.999) == "1.00"
@test fmt(".2f", 0.996) == "1.00"
@test fmt("6.2f", 9.999) == " 10.00"
# Floating point error can upset this one (i.e. 0.99500000 or 0.994999999)
@test (fmt(".2f", 0.995) == "1.00" || fmt(".2f", 0.995) == "0.99")
@test fmt(".2f", 0.994) == "0.99"

# format floating point (e)

@test fmt("E", 0.0) == "0.000000E+00"
@test fmt("e", 0.0) == "0.000000e+00"
@test fmt("e", 0.001) == "1.000000e-03"
@test fmt("e", 0.125) == "1.250000e-01"
@test fmt("e", 100/3) == "3.333333e+01"
@test fmt("e", -0.125) == "-1.250000e-01"
@test fmt("e", -100/6) == "-1.666667e+01"
@test fmt("e", 1234.5678) == "1.234568e+03"
@test fmt("8e", 1234.5678) == "1.234568e+03"

@test fmt("<12.2e", 13.89) == "1.39e+01    "
@test fmt(">12.2e", 13.89) == "    1.39e+01"
@test fmt("*<12.2e", 13.89) == "1.39e+01****"
@test fmt("⋆<12.2e", 13.89) == "1.39e+01⋆⋆⋆⋆"
@test fmt("*>12.2e", 13.89) == "****1.39e+01"
@test fmt("⋆>12.2e", 13.89) == "⋆⋆⋆⋆1.39e+01"
@test fmt("012.2e", 13.89) == "00001.39e+01"
@test fmt("012.2e", -13.89) == "-0001.39e+01"
@test fmt("+012.2e", 13.89) == "+0001.39e+01"

@test fmt(".1e", 0.999) == "1.0e+00"
@test fmt(".1e", 0.996) == "1.0e+00"
# Floating point error can upset this one (i.e. 0.99500000 or 0.994999999)
@test (fmt(".1e", 0.995) == "1.0e+00" || fmt(".1e", 0.995) == "9.9e-01")
@test fmt(".1e", 0.994) == "9.9e-01"
@test fmt(".1e", 0.6) == "6.0e-01"
@test fmt(".1e", 0.9) == "9.0e-01"

# issue #61
@test fmt("1.0e", 1e-21) == "1.e-21"
@test fmt("1.1e", 1e-21) == "1.0e-21"

@test fmt("10.2e", 1.2e100) == " 1.20e+100"
@test fmt("11.2e", BigFloat("1.2e1000")) == " 1.20e+1000"
@test fmt("11.2e", BigFloat("1.2e-1000")) == " 1.20e-1000"
@test fmt("9.2e", 9.999e9) == " 1.00e+10"
@test fmt("10.2e", 9.999e99) == " 1.00e+100"
@test fmt("11.2e", BigFloat("9.999e999")) == " 1.00e+1000"
@test fmt("10.2e", -9.999e-100) == " -1.00e-99"

# issue #84
@test fmt("+11.3e", 1.0e-309) == "+1.000e-309"
@test fmt("+11.3e", 1.0e-313) == "+1.000e-313"

# format special floating point value

@test fmt("f", NaN) == "NaN"
@test fmt("e", NaN) == "NaN"
@test fmt("f", NaN32) == "NaN"
@test fmt("e", NaN32) == "NaN"

@test fmt("f", Inf) == "Inf"
@test fmt("e", Inf) == "Inf"
@test fmt("f", Inf32) == "Inf"
@test fmt("e", Inf32) == "Inf"

@test fmt("f", -Inf) == "-Inf"
@test fmt("e", -Inf) == "-Inf"
@test fmt("f", -Inf32) == "-Inf"
@test fmt("e", -Inf32) == "-Inf"

@test fmt("<5f", Inf) == "Inf  "
@test fmt(">5f", Inf) == "  Inf"
@test fmt("*<5f", Inf) == "Inf**"
@test fmt("⋆<5f", Inf) == "Inf⋆⋆"
@test fmt("*>5f", Inf) == "**Inf"
@test fmt("⋆>5f", Inf) == "⋆⋆Inf"

