# performance testing

using Format

# performance of format parsing

fp1() = FormatExpr("{1} + {2} + {3}")

fp1()
@time for i=1:10000; fp1(); end

fp2() = FormatExpr("abc {1:*<5d} efg {2:*>8.4e} hij")

fp2()
@time for i=1:10000; fp2(); end

# performance of string formatting

const fe1 = fp1()
const fe2 = fp2()

sf1(x, y, z) = format(fe1, x, y, z)
sf1(10, 20, 30)
@time for i=1:10000; sf1(10, 20, 30); end

sf2(x, y) = format(fe2, x, y)
sf2(10, 20)
@time for i=1:10000; sf2(10, 20); end

