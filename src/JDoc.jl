module JDoc

export @doc_str, @doc_mstr, jdoc, DocNode

# String macros -- Sole purpose is to denote docstrings.
macro doc_str(str)   str  end
macro doc_mstr(str)  str  end

doc"
= JDoc.jl
Daniel Carrera
v0.1 alpha

Documentation system for Julia.
"

type DocNode
	tag::Symbol
	content::Array{Union(DocNode,String)}
	meta::Dict
	
	DocNode(tag)            = new(tag,Item[],Dict())
	DocNode(tag,meta::Dict) = new(tag,Item[],meta)
	DocNode(tag,str::String)      = new(tag,mysplit(str),Dict())
	DocNode(tag,str::String,meta) = new(tag,mysplit(str),meta)
end

########################################
doc"
== API

Basic ussage:

----
using JDoc

str = readdoc(\"example.jl\")

doc = jdoc(str)

println( reprmime(\"text/html\", doc) )
----
"
import Base: writemime

writemime(io, ::MIME"text/plain", doc::DocNode) = write(io, doc.meta[:docstr])
writemime(io, ::MIME"text/html" , doc::DocNode) = write(io, to_html(doc)  )
writemime(io, ::MIME"text/dump" , doc::DocNode) = write(io, to_dump(doc)  )

########################################
doc"
== Writing manuals
"
include("lib/backend.jl")
include("lib/frontend.jl")

########################################
doc"
== Writing manuals
"
include("lib/readdoc.jl")
include("lib/parser.jl")
include("lib/to_dump.jl")
include("lib/to_html.jl")

end
