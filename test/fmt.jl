using Format
using Base.Test

# some basic functionality testing
x = 1234.56789

@test fmt(x) == "1234.567890"
@test fmt(x;prec=2) == "1234.57"
@test fmt(x,10,3) == "  1234.568"
@test fmt(x,10,3,:left) == "1234.568  "
@test fmt(x,10,3,:ljust) == "1234.568  "
@test fmt(x,10,3,:right) == "  1234.568"
@test fmt(x,10,3,:lrjust) == "  1234.568"
@test fmt(x,10,3,:zpad) == "001234.568"
@test fmt(x,10,3,:zeropad) == "001234.568"
@test fmt(x,:commas) == "1,234.567890"
@test fmt(x,10,3,:left,:commas) == "1,234.568 "
@test fmt(x,:ipre) == "1234.567890"

i = 1234567

@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

@test_throws ErrorException fmt_default(Real)

fmt_default!(Int, :commas, width = 12)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1234.567890"  # default hasn't changed

fmt_default!(:commas)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1,234.567890"  # width hasn't changed, but added commas

fmt_default!(Int) # resets Integer defaults
@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

reset!(Int)
fmt_default!(UInt16, 'd', :commas)
@test fmt(0xffff) == "65,535"
fmt_default!(UInt32, UInt16, width=20)
@test fmt(0xfffff) == "           1,048,575"
