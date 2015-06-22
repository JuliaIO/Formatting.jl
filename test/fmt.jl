
using Formatting
using Base.Test

# some basic functionality testing
x = 1234.56789

@test fmt(x) == "1234.567890"
@test fmt(x,2) == "1234.57"
@test fmt(x,3,10) == "  1234.568"
@test fmt(x,3,10,:left) == "1234.568  "
@test fmt(x,3,10,:ljust) == "1234.568  "
@test fmt(x,:commas) == "1,234.567890"

i = 1234567

@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

fmt_default!(Int, :commas, width = 12)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1234.567890"  # default hasn't changed

fmt_default!(:commas)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1,234.567890"  # width hasn't changed, but added commas

fmt_default!(Int) # resets Integer defaults
@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

