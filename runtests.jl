tests = ["fmtspec", 
         "formatexpr"]

for t in tests
    fp = joinpath("test", string(t, ".jl"))
    println("  running $fp ...")
    include(fp)
end

