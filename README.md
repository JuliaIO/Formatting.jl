# Formatting

A Julia package for Python-like formatting.
[![Build Status](https://travis-ci.org/lindahua/Formatting.jl.png?branch=master)](https://travis-ci.org/lindahua/Formatting.jl)

---------------


## Getting Started

This package is pure Julia. Setting up this package is like setting up other Julia packages:

```julia
Pkg.add("Formatting")
```

To start using the package, you can simply write

```julia
using Formatting
```

## Types and Functions

This package has two types ``FormatSpec`` and ``FormatExpr`` to represent a format specification.

In particular, ``FormatSpec`` is used to capture the specification of a single entry. One can compile a format specification string into a ``FormatSpec`` instance as

```julia
fmt = FormatSpec("d")
fmt = FormatSpec("<8.4f")
```

``FormatExpr`` captures a formatting expression that may involve multiple items. One can compile a formatting string into a ``FormatExpr`` instance as

```julia
fe = FormatExpr("{1} + {2}")
fe = FormatExpr("{1:d} + {2:08.4e} + {3|>abs2}")
```



