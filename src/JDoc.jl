module JDoc

# String macros -- Sole purpose is to denote docstrings.
macro doc_str(str)   str  end
macro doc_mstr(str)  str  end

export @doc_str, @doc_mstr

doc"
= JDoc.jl
Daniel Carrera

Documentation system for Julia.

== Online help
"
include("lib/backend.jl")
include("lib/frontend.jl")

doc"
== Writing manuals
"
include("lib/readdoc.jl")
include("lib/parser.jl")
include("lib/to_tree.jl")

end
