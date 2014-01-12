"""
=== JDoc markup

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

export parse_jdoc, JNode

type JNode
	tag::Symbol
	content::Array{Union(JNode,String)}
	meta::Dict
	
	JNode(tag)            = new(tag,Item[],Dict())
	JNode(tag,meta::Dict) = new(tag,Item[],meta)
	JNode(tag,str::String)      = new(tag,mysplit(str),Dict())
	JNode(tag,str::String,meta) = new(tag,mysplit(str),meta)
end

typealias Item Union(JNode,String)

#
# Convenience functions.
#
is(obj,tag) = isa(obj, JNode) && obj.tag == tag

mysplit(str)  = split(str, "\n", true) # Retain blank lines.
myjoin(lines) = join(lines, "\n")      # Undo mysplit().

isblank(node::JNode) = all(node.content .== "")
append!(node::JNode,item::Item) = push!(node.content, item)

#
# This function parses a JuliaDoc string and returns an object.
#
function parse_jdoc(docstr::String)
	
	root = JNode(:root, docstr)
	
	parse_blocks!(root)
	parse_sections!(root)
	
	return root
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                  B L O C K S                  #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_blocks!(obj::JNode)
	# New content.
	content = Item[]
	
	# Types of block.
	function query(str, q)
		if str == "...."  return (q? :literal : :verbatim)  end
		if str == "----"  return (q? :listing : :verbatim)  end
		if str == "===="  return (q? :example : :normal  )  end
		if str == "****"  return (q? :sidebar : :normal  )  end
		if str == "____"  return (q? :verse   : :normal  )  end
		if str == "////"  return (q? :comment : :other   )  end
		if str == "|==="  return (q? :table   : :other   )  end
		if str == "++++"  return (q? :pass    : :other   )  end
		return :none
	end
	block(str) = query(str, true)
	group(str) = query(str, false)
	inblock = false
	
	#
	# Every item is a line of text.
	#
	for line in obj.content
		if inblock
			if block(line) == content[end].meta[:style]
				# End of current block.
				inblock = false
			else
				append!(content[end],line)
			end
		else
			if block(line) == :none
				push!(content,line)
			else
				# Start of a new block.
				meta = { :style => block(line), :group => group(line) }
				push!(content, JNode(:block,meta) )
				inblock = true
			end
		end
	end
	
	# Remove comments
	obj.content = filter(x -> isa(x,String)||x.meta[:style]!=:comment, content)
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                S E C T I O N S                #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_sections!(obj::JNode, level::Integer=0)
	#
	# All sections begin with a (possibly empty) preamble.
	#
	content = Item[ JNode(:preamble) ]
	heading = Regex("^={$(level+1)}\s*([^=].*)\$")
	
	#
	# Content is an array of strings and block nodes.
	#
	for item in obj.content
		
		if isa(item,String) && ismatch(heading, item)
			# New section.
			meta = {
				:level => level,
				:title => strip(match(heading, item).captures[1])
			}
			push!(content, JNode(:section,meta) )
		else
			# Add (string|block) to the current (section|preamble).
			append!(content[end], item)
		end
	end
	
	# Special rules for top-level headings
	if level == 0
		if length(content) > 2
			error("Only one top-level section allowed.")
		end
		if length(content) == 2
			# Have exactly one level 0 section.
			if !isblank(content[1])
				error("No text allowed before a level-0 section.")
			end
			
			# Read the author and revision if any.
			if ismatch(r"\w", content[2].content[1])
				content[2].meta[:author] = shift!(content[2].content)
				if ismatch(r"\w", content[2].content[1])
					content[2].meta[:revision] = shift!(content[2].content)
				end
			end
		end
	end
	
	# Parse lower-level headings.
	if level < 4
		for item in content
			if is(item, :section) parse_sections!(item, level+1) end
		end
	end
	
	#
	# Manage preambles.
	#
	if isblank(content[1])
		shift!(content) # Remove blank preambles (always for level-0).
	elseif length(content) == 1
		content = content[1].content # Remove needless nesting into preambles.
	end
	
	obj.content = content
end

