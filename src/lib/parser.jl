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
function mysplit(str)
	split(str, "\n", true)
end
function myjoin(lines)
	join(lines, "\n")
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
function JDoc(str::String)
	
	root = Node(:root, docstr)
	
	parse_blocks!(root)
	parse_headings!(root)
	
	
	toplevel(o) = isa(o, Node) && o.tag == :section && o.meta[:level] == 1
	
	if toplevel(root.content[1])
		return root.content[1]
	else
		return root
	end
end

# - - - - - - - - - - - + - - - - - - - - - - - #
#                  B L O C K S                  #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_blocks!(obj::Node)
	# New content.
	content = Item[]
	
	# Types of block.
	comment = r"^////"
	example = r"^===="
	literal = r"^...."
	listing = r"^----"
	sidebar = r"^****"
	verse = r"^____"
	table = r"^!==="
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                H E A D I N G S                #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_headings!(obj::Node, level::Integer=1)
	# New content.
	content = Item[]
	
	regex = Regex("^={$level}\s*([^=].*)\$")
	blank = true
	
	#
	# When parsing headings, the content is always a single string.
	#
	for line in mysplit(obj.content)
		if ismatch(regex,line)
			meta = {
				:level => level,
				:title => strip(match(regex,line).captures[1])
			}
			push!(content, Node(:section,"",meta))
			blank = true
		else
			if length(content) == 0
				push!(content, line)
			else
				if isa(content[end],String)
					content[end] *= "\n" * line
				else
					# Inside a section.
					content[end].content *= (blank ? "" : "\n") * line
					blank = false
				end
			end
		end
	end
	
	#
	# Speical rules for top-level headings
	#
	if level == 1
		while isa(content[1], String) && ismatch(r"\s*", content[1])
			shift!(content)
		end
		if isa(content[1], String)
			error("No text allowed before the title.")
		end
		if length(content) > 1
			error("Only one top-level section allowed.")
		end
		
		#
		# Read the author and revision if any.
		#
		lines = mysplit(content[1].content)
		if ismatch(r"\w", lines[1])
			content[1].meta[:author] = shift!(lines)
			if ismatch(r"\w", lines[1])
				content[1].meta[:revision] = shift!(lines)
			end
			content[1].content = myjoin(lines)
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
