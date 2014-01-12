doc"
=== Backend

The backend defines the contents of the global `DOC` object, and how the
`help()` and `apropos()` functions look inside that object. In this way,
the backend determines how the frontend macro--`@doc`--needs to populate
the `DOC` object.

`DOC` is a global dictionary of type `DocDict`. The keys are string
representations of functions, methods or other Julia objects. The values
are `DocEntry` objects which themselves are dictionaries, indexed by
symbols such as `:author`, `:date` and `:doc`.
"

export DOC, DocEntry, DocDict

import Base: help

typealias DocEntry Dict{Any,Any}
typealias DocDict  Dict{Any,DocEntry}

DOC = DocDict()

help(key) = show(haskey(DOC,key) ? DOC[key][:doc] : "No help for `$key`")
