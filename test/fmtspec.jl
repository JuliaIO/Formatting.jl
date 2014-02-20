# test format spec parsing

using Formatting
using Base.Test


# default spec
fs = FormatSpec(2, "")
@test fs.iarg == 2
@test fs.typ == 's'
@test fs.fill == '\0'
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
@test FormatSpec(1, "12.6f") == FormatSpec(1, 'f'; width=12, prec=6)
@test FormatSpec(1, "+08o") == FormatSpec(1, 'o'; width=8, zpad=true, sign='+')

@test FormatSpec(1, "8") == FormatSpec(1, 's'; width=8)
@test FormatSpec(1, ".6f") == FormatSpec(1, 'f'; prec=6)
@test FormatSpec(1, "<8d") == FormatSpec(1, 'd'; width=8, align='<')
@test FormatSpec(1, "#<8d") == FormatSpec(1, 'd'; width=8, fill='#', align='<')
@test FormatSpec(1, "#8,d") == FormatSpec(1, 'd'; width=8, ipre=true, tsep=true)

