using Formatting
using Base.Test


# with positional arguments

@test format("{1}", 10) == "10"
@test format("abc {1}", 10) == "abc 10"
@test format("{1} efg", 10) == "10 efg"
@test format("abc {1} efg", 10) == "abc 10 efg"
@test format("{1} + {2}", 10, "xyz") == "10 + xyz"
@test format("abc {1} + {2}", 10, "xyz") == "abc 10 + xyz"
@test format("{1} + {2} efg", 10, "xyz") == "10 + xyz efg"
@test format("abc {1} + {2} efg", 10, "xyz") == "abc 10 + xyz efg"
@test format("abc {1}{2} efg", 10, "xyz") == "abc 10xyz efg"

@test format("{1:d} + {2:s}", 10, "xyz") == "10 + xyz"
@test format("{1:04d} + {2:*>5}", 10, "xyz") == "0010 + **xyz"
@test format("let {2:<5} := {1:.4f};", 12.3, "var") == "let var   := 12.3000;"

