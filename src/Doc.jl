module Doc

export DOC, DocEntry, DocDict
export @doc, @doc_str, @doc_mstr
export docdoc, DocNode, readdoc, man


# String macros -- Sole purpose is to denote docstrings.
macro doc_str(str)   str  end
macro doc_mstr(str)  str  end

doc"
== Doc.jl

----
Author:  Daniel Carrera
Version: v0.1.0-alpha
----

A modern documentation system for Julia.

Doc.jl is a documentation module for Julia. It provides features for
both online help and for writing manual-style documentation. Doc.jl is
currently alpha software. If you are feeling adventurous, you are
encouraged to give it a try. This page summarizes the current status of
Doc.jl, and a description of the *DocDoc* markup format. You may complement
this document with the wiki. This document is divided in three parts:


API:: A lightning tour of the Doc.jl API, for those who want to write their
own scripts using DocDoc.

Online help:: How Doc.jl will let you add your function's documentation to
the online help.

Manuals:: How Doc.jl will make it easier for you to write and maintain a
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
=== API

Basic usage:

----
using DocDoc

doc\"
This is a docstring. Docstrings contain program documentation
that can be extracted and parsed by the DocDoc module.
\"

# Extract docstrings from a file.
str = readdoc(\"example.jl\")

# Parse the string as DocDoc markup.
doc = docdoc(str)

# Convert to HTML.
writemime(STDOUT, \"text/html\", doc)
----

docstring:: A documentation string -- _docstring_ -- is a string literal of
the form `doc\" ... \"` or `doc\"\"\" ... \"\"\"`. They are used to mark
source documentation that is not part of the online help.

readdoc(_source_):: Given an IO stream or file name, this function extracts
all the docstrings, respecting `include` directives.

docdoc(_docstr_):: Takes a string and parses it as *DocDoc* markup. The resulting
object can be converted to various formats such as HTML and LaTeX.

writemime(_stream, mime, doc_):: Doc.jl uses the  `writemime` framework
to convert documentation objects into other formats. Currently supported
MIME types include:

|===
|`text/plain` | Raw docstring without any processing.
|`text/xml`   | Convert to XML (Docbook).
|`text/html`  | Convert to HTML.
|`text/dump`  | Produce a dump tree useful for debugging.
|===
"
import Base: writemime

writemime(io, ::MIME"text/xml"  , doc::DocNode) = write(io, to_xml(doc))
writemime(io, ::MIME"text/html" , doc::DocNode) = write(io, to_html(doc))
writemime(io, ::MIME"text/dump" , doc::DocNode) = write(io, to_dump(doc) * "\n")
writemime(io, ::MIME"text/plain", doc::DocNode) = write(io, to_dump(doc) * "\n")

########################################

include("lib/help.jl")

########################################
doc"
=== Writing manuals

==== Command-line program: `docdoc`

This module includes a short script called `docdoc`, which uses the API described
above to extract and process documentation in Julia files. The program can print
the original raw string, or convert it to supported formats:

----
docdoc example.jl          # Output raw docstring.
docdoc --plain example.jl  # Output raw docstring.
docdoc --dump  exampe.jl   # Output a dump tree.
docdoc --html  exampe.jl   # Output HTML.
docdoc --xml   exampe.jl   # Output XML (Docbook).
----
"
include("lib/parser.jl")
include("lib/readdoc.jl")
include("lib/to_dump.jl")
include("lib/to_html.jl")
include("lib/to_xml.jl")

end
