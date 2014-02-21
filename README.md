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

#### Types to Represent Formats

This package has two types ``FormatSpec`` and ``FormatExpr`` to represent a format specification.

In particular, ``FormatSpec`` is used to capture the specification of a single entry. One can compile a format specification string into a ``FormatSpec`` instance as

```julia
fspec = FormatSpec("d")
fspec = FormatSpec("<8.4f")
```
Please refer to [Python's format specification language](http://docs.python.org/2/library/string.html#formatspec) for details.


``FormatExpr`` captures a formatting expression that may involve multiple items. One can compile a formatting string into a ``FormatExpr`` instance as

```julia
fe = FormatExpr("{1} + {2}")
fe = FormatExpr("{1:d} + {2:08.4e} + {3|>abs2}")
```
Please refer to [Python's format string syntax](http://docs.python.org/2/library/string.html#format-string-syntax) for details.


**Note:** If the same format is going to be applied for multiple times. It is more efficient to first compile it.


#### Formatted Printing

One can use ``printfmt`` and ``printfmtln`` for formatted printing:

- **printfmt**(io, fe, args...)

- **printfmt**(fe, args...)

    Print given arguments using given format ``fe``. Here ``fe`` can be a formatting string, an instance of ``FormatSpec`` or ``FormatExpr``.
    
    **Examples**
    
    ```julia
    printfmt("{1:>4s} + {2:.2f}", "abc", 12) # --> print(" abc + 12.00")
    printfmt("{} = {:#04x}", "abc", 12) # --> print("abc = 0x0c") 
    
    fs = FormatSpec("#04x")
    printfmt(fs, 12)   # --> print("0x0c")
    
    fe = FormatExpr("{} = {:#04x}")
    printfmt(fe, "abc", 12)   # --> print("abc = 0x0c")
    ```
    
- **printfmtln**(io, fe, args...)

- **printfmtln**(fe, args...)

    Similar to ``printfmt`` except that this function print a newline at the end.

#### Formatted String

One can use ``fmt`` to format a single value into a string, or ``format`` to format one to multiple arguments into a string using an format expression.

- **fmt**(fspec, a)

    Format a single value using a format specification given by ``fspec``, where ``fspec`` can be either a string or an instance of ``FormatSpec``.
    
- **format**(fe, args...)

    Format arguments using a format expression given by ``fe``, where ``fe`` can be either a string or an instance of ``FormatSpec``.


## Difference from Python's Format

At this point, this package implements a subset of Python's formatting language (with slight modification). Here is a summary of the differences:

- ``g`` and ``G`` for floating point formatting have not been supported yet. Please use ``f``, ``e``, or ``E`` instead.

- The package currently provides default alignment, left alignment ``<`` and right alignment ``>``. Other form of alignment such as centered alignment ``^`` has not been supported yet.

- In terms of argument specification, it supports natural ordering (e.g. ``{} + {}``), explicit position (e.g. ``{1} + {2}``). It hasn't supported named arguments or fields extraction yet. Note that mixing these two modes is not allowed (e.g. ``{1} + {}``).

- The package provides support for filtering (for explicitly positioned arguments), such as ``{1|>lowercase}`` by allowing one to embed the ``|>`` operator, which the Python counter part does not support.

