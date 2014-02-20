# test format spec parsing

using Formatting
using Base.Test


# default spec
fs = FormatSpec(2, "")
@test fs.iarg == 2
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

fs = FormatSpec(1, "d")
@test fs == FormatSpec(1, 'd')
@test fs.align == '>'

@test FormatSpec(1, "8x") == FormatSpec(1, 'x'; width=8)
@test FormatSpec(1, "08b") == FormatSpec(1, 'b'; width=8, zpad=true)
@test FormatSpec(1, "12f") == FormatSpec(1, 'f'; width=12, prec=6)
@test FormatSpec(1, "12.7f") == FormatSpec(1, 'f'; width=12, prec=7)
@test FormatSpec(1, "+08o") == FormatSpec(1, 'o'; width=8, zpad=true, sign='+')

@test FormatSpec(1, "8") == FormatSpec(1, 's'; width=8)
@test FormatSpec(1, ".6f") == FormatSpec(1, 'f'; prec=6)
@test FormatSpec(1, "<8d") == FormatSpec(1, 'd'; width=8, align='<')
@test FormatSpec(1, "#<8d") == FormatSpec(1, 'd'; width=8, fill='#', align='<')
@test FormatSpec(1, "#8,d") == FormatSpec(1, 'd'; width=8, ipre=true, tsep=true)

# format string

@test fmt("", "abc") == "abc"
@test fmt("s", "abc") == "abc"
@test fmt("2s", "abc") == "abc"
@test fmt("5s", "abc") == "abc  "
@test fmt(">5s", "abc") == "  abc"
@test fmt("*>5s", "abc") == "**abc"
@test fmt("*<5s", "abc") == "abc**"

# format char

@test fmt("", 'c') == "c"
@test fmt("c", 'c') == "c"
@test fmt("3c", 'c') == "c  "
@test fmt(">3c", 'c') == "  c"
@test fmt("*>3c", 'c') == "**c"
@test fmt("*<3c", 'c') == "c**"

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
@test fmt("*>6d", 123) == "***123"
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


