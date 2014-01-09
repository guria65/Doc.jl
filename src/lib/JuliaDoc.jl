"""
=== JuliaDoc

JuliaDoc is a human-readable markup language. It is a small
subset of AsciiDoc, intended to provide enough features for
source code documentation while keeping the implementation
simple.

JuliaDoc can be naturally extended by using additional features
from AsciiDoc and a standard AsciiDoc processor. The two main
implementations are http://asciidoc.org[asciidoc] and
http://asciidoctor.org[Asciidoctor].

==== Status

So far I have only implemented a basic data structure to hold
the parsed documentation. The next step is to parse JuliaDoc
into this data structure and then convert to other formats
like HTML.
"""

type Node
	tag::Symbol
	contents::Array{Union(Node,String)}
	Node(tag,cont) = new(tag, [cont])
end

type JDoc
	docstring::String
	root::Node
	JDoc(docstr) = new(docstr, Node(:root,docstr))
end


#
# This function parses a JuliaDoc string and returns an object.
#
function JuliaDoc(str::String)
	
	JDoc(str)
	
end






