module JDoc

# String macros -- Sole purpose is to denote docstrings.
macro doc_str(str)   str  end
macro doc_mstr(str)  str  end

export @doc_str, @doc_mstr

doc"
= JDoc.jl
Daniel Carrera
v0.1 alpha

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
include("lib/to_dump.jl")
include("lib/to_html.jl")

doc"
== API

Basic ussage:

----
using JDoc

str = readdoc(\"example.jl\")

doc = jdoc(str)

println( reprmime(::MIME\"text/html\", doc) )
----

"

Base.writemime(stream, ::MIME"text/html", doc::DocNode) = to_html(doc)
Base.writemime(stream, ::MIME"text/dump", doc::DocNode) = to_dump(doc)


end
