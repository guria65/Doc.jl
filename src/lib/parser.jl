"""
== JDoc

JDoc is a human-readable markup language. It is a small subset of AsciiDoc,
intended to provide enough features for source code documentation while
keeping the implementation simple.

JDoc can be naturally extended by using additional features from AsciiDoc
and a standard AsciiDoc processor. The two main implementations are
http://asciidoc.org[asciidoc] and http://asciidoctor.org[Asciidoctor].

=== Status

I can currently parse the simplest type of heading:

----
= Head 1

== Head 2

=== Head 3

==== Head 4

===== Head 5
----

I have also implemented a basic tree data structure to hold the
parsed documentation. The next step is to parse JuliaDoc into
this data structure and then convert to other formats like HTML.
"""

type Node
	tag::Symbol
	content::Union(String,Array{Union(Node,String)})
	meta::Dict
	
	Node(tag,content)      = new(tag,content,Dict())
	Node(tag,content,meta) = new(tag,content,meta)
end

typealias Item Union(Node,String)

#
# Empty lines have syntactic meaning. Be sure to keep them.
#
function lines(str)
	split(str, "\n", true)
end

#
# Convenience function.
#
function items(obj::Node)
	typeof(obj.content) == String ? [obj.content] : obj.content
end


#
# This function parses a JuliaDoc string and returns an object.
#
function JuliaDoc(str::String)
	
	root = Node(:root, docstr)
	
	#
	# Parse all headings (single-line headings).
	#
	parse_headings!(root)
	
	return root
end

function parse_headings!(obj::Node, level::Integer=1)
	content = Item[] # New content.
	
	regex = Regex("^={$level}\s*([^=].*)\$")
	
	#
	# When parsing headings, the content is always a single string.
	#
	for line in lines(obj.content)
		if ismatch(regex,line)
			meta = {
				:level => level,
				:title => strip(match(regex,line).captures[1])
			}
			push!(content, Node(:section,"",meta))
		else
			if length(content) == 0
				push!(content, line)
			else
				if isa(content[end],String)
					content[end] *= "\n" * line
				else
					# Last item must be section node.
					content[end].content *= "\n" * line
				end
			end
		end
	end
	
	#
	# Parse lower-level headings.
	#
	if level < 5
		for item in content
			if isa(item,Node)
				parse_headings!(item, level+1)
			end
		end
	end
	
	
	obj.content = content
end


