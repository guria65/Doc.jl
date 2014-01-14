module JDoc

export DOC, DocEntry, DocDict
export @doc, @doc_str, @doc_mstr
export jdoc, DocNode


# String macros -- Sole purpose is to denote docstrings.
macro doc_str(str)   str  end
macro doc_mstr(str)  str  end

doc"
= JDoc.jl
Daniel Carrera
v0.1 alpha

A modern documentation system for Julia.

JDoc.jl is a documentation module for Julia. It provides features for
both online help and for writing manual-style documentation. JDoc is
currently alpha software. If you are feeling adventurous, you are
ecouraged to give it a try.

This page summarizes the current status of JDoc.jl, and a description of
the JDoc markup format. You may complement this document with the wiki.
This document is divided in three parts:


API:: A lightining tour of the JDoc API, for those who want to write their
own scripts using JDoc.

Online help:: How JDoc will let you add your function's documentation to
the `help()` command.

Manuals:: How JDoc will make it easier for you to write and maintain a
manual for your product.
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

doc\"
This is a docstring. Docstrings contain program documentation
that can be extracted and parsed by the JDoc module.
\"

# Extract docstrings from a file.
str = readdoc(\"example.jl\")

# Parse the string as JDoc markup.
doc = jdoc(str)

# Convert to HTML.
writemime(STDOUT, \"text/html\", doc)
----
"
import Base: writemime

writemime(io, ::MIME"text/plain", doc::DocNode) = write(io, doc.meta[:docstr])
writemime(io, ::MIME"text/html" , doc::DocNode) = write(io, to_html(doc)  )
writemime(io, ::MIME"text/dump" , doc::DocNode) = write(io, to_dump(doc) * "\n" )

########################################

include("lib/help.jl")

########################################
doc"
== Writing manuals
"
include("lib/readdoc.jl")
include("lib/parser.jl")
include("lib/to_dump.jl")
include("lib/to_html.jl")

end
