doc"
==== JDoc markup

JDoc is a human-readable markup language. It is a small subset of AsciiDoc,
intended to provide enough features for source code documentation while
keeping the implementation simple. JDoc can be naturally extended by using
additional features from AsciiDoc and a standard AsciiDoc processor. The
two main implementations are http://asciidoc.org[asciidoc] and
http://asciidoctor.org[Asciidoctor]. The current parser supports the
following features:

Headings::
----
= Head 1

== Head 2

=== Head 3

==== Head 4

===== Head 5
----


Paragraphs:: Including admonition paragraphs (TIP, NOTE, WARNING, CAUTION
IMPORTANT.):
----
This is a paragraph.

TIP: This is a paragraph.

NOTE: This is a paragraph.

WARNING: This is a paragraph.

CAUTION: This is a paragraph.

IMPORTANT: This is a paragraph.
----

Blocks:: Most block types supported. Tables are passed verbatim.
----
  ....
  Literal line 1
  Literal line 2
  ....
  
  ----
  Listing line 1
  Listing line 2
  ----
  
  ====
  Example line 1
  Example line 2
  ====
  
  ****
  Sidebar line 1
  Sidebar line 2
  ****
  
  ____
  Verse line 1
  Verse line 2
  ____
  
  |===
  Table line 1
  Table line 2
  |===
  
  ++++
  Pass line 1
  Pass line 2
  ++++
  
  ////
  Comment line 1
  Comment line 2
  ////
----
"

typealias Item Union(DocNode,String)

#
# Convenience functions.
#
is(obj,tag) = isa(obj,DocNode) && obj.tag == tag

mysplit(str)  = split(str, "\n", true) # Retain blank lines.
myjoin(lines) = join(lines, "\n")      # Undo mysplit().

isblank(node::DocNode) = all(node.content .== "")
append!(node::DocNode,item::Item) = push!(node.content, item)

#
# Which objects should be processed.
#
process(obj::DocNode) = !in(obj.tag, [:literal, :listing, :pass, :table])
process(other) = false
	


#
# This function parses a JuliaDoc string and returns an object.
#
function jdoc(docstr::String)
	
	root = DocNode(:root, docstr)
	
	parse_blocks!(root)
	parse_sections!(root)
	parse_lists!(root)
	parse_paragraphs!(root)
	
	return root
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                   L I S T S                   #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_lists!(obj::DocNode)
	# New content.
	content = Item[]
	
	#
	# NOTE: ':pragraph' includes admonition paragraphs.
	#
	style(obj::DocNode) = islist(obj) ? obj.tag : :none
	function style(str::String)
		ismatch(r"^\s*$"    , str) && return :blank
		ismatch(r"^\s*[\d.]+\s", str) && return :ordered
		ismatch(r"^\s*[*-]\s"  , str) && return :itemized
		ismatch(r"^\s*\S.*::\s", str) && return :variable
		ismatch(r"^\s*\S"      , str) && return :paragraph
		
		# This should never be reached.
		error("Could not recognize pattern for '$str'")
	end
	islist(obj::DocNode) = in(obj.tag   , [:ordered,:itemized,:variable])
	islist(str::String)  = in(style(str), [:ordered,:itemized,:variable])
	ispara(str::String)  = style(str) == :paragraph
	
	#
	# "list" is a list object, containing many list items.
	#
	function create_new_listitem!(list::DocNode,str::String)
		if list.tag == :variable
			#
			# RULE: Find the *LAST* spot with :: followed by a space.
			# 
			term, def = match(r"^\s*(\S.*)::\s(.*)", str).captures
			
			def  = convert(UTF8String, def)
			term = convert(UTF8String, rstrip(term))
			
			append!(list, DocNode(:listitem, def, {:term => rstrip(term)}))
			
		elseif list.tag == :ordered
			#
			# Numbered lists can have numbers.
			#
			regex = ismatch(r"^\s*\d+\.", str) ? r"^\s*\d+\.(.*)" : r"^\s*\.(.*)"
			str   = convert(UTF8String, lstrip(match(regex, str).captures[1]))
			append!(list, DocNode(:listitem, str))
		else
			# Remove itemized.
			str = convert(UTF8String, lstrip(lstrip(str)[2:end]))
			append!(list, DocNode(:listitem, str))
		end
	end
	append_to_listitem!(list::DocNode,obj) = append!(list.content[end],obj)
	
	#
	# Start with a blank list item.
	#
	prev = ""
	for item in obj.content
		
		if isa(item,DocNode)
			# Block or new section => Any list must terminate.
			process(item) && parse_lists!(item)
			push!(content, item)
		elseif style(item) == :paragraph && prev == ""
			push!(content, item) # New para => Any list must terminate.
		elseif length(content) > 0 && islist(content[end])
			
			if in(style(item), [:blank,:paragraph])
				#
				# IF :paragraph
				#		=> prev must be ""
				#		=> still inside the list item.
				# 
				append_to_listitem!(content[end], item)
			else
				#
				# RULE: Indentation is irrelevant
				#       => variable lists cannot nest directly.
				#
				if style(item) != style(content[end])
					append_to_listitem!(content[end], item)
				else
					create_new_listitem!(content[end], item)
				end
			end
		elseif islist(item)
			# Start new list.
			push!(content, DocNode(style(item)))
			create_new_listitem!(content[end], item)
		else
			push!(content, item) # Nothing to do.
		end
		prev = item
	end
	
	obj.content = content
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#              P A R A G R A P H S              #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_paragraphs!(obj::DocNode)
	# New content.
	content = Item[]
	
	# Paragraph types and labels.
	query(node::DocNode,q) = q ? :none : ""
	function query(str::String,q)
		beginswith(str,"TIP:"      ) && return q ? :tip       : "TIP:"      
		beginswith(str,"NOTE:"     ) && return q ? :note      : "NOTE:"     
		beginswith(str,"WARNING:"  ) && return q ? :warning   : "WARNING:"  
		beginswith(str,"CAUTION:"  ) && return q ? :caution   : "CAUTION:"  
		beginswith(str,"IMPORTANT:") && return q ? :important : "IMPORTANT:"
		
		ismatch(r"^\s*$", str) && return q ? :none : error("No label")
		return q ? :para : ""
	end
	para(obj)  = query(obj,true)
	label(str) = query(str,false)
	
	# Remove the first occurrence of the label, and trailing spaces.
	function rmlabel(str::String)
		l = label(str)
		l == "" ? str : lstrip(replace(str,l,"",1))
	end
	
	inpara = false
	for item in obj.content
		if para(item) == :none
			process(item) && parse_paragraphs!(item)
			push!(content,item)
			inpara = false
		else
			# Is a string, and not blank.
			if inpara
				append!(content[end],item)
			else
				# New pararaph.
				push!(content, DocNode(para(item)))
				append!(content[end], rmlabel(item))
				inpara = true
			end
		end
	end
	
	obj.content = content
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                  B L O C K S                  #
# - - - - - - - - - - - + - - - - - - - - - - - #

function parse_blocks!(obj::DocNode)
	# New content.
	content = Item[]
	
	# Types of block.
	function query(str, q)
		if str == "...."  return (q? :literal : :verbatim)  end
		if str == "----"  return (q? :listing : :verbatim)  end
		if str == "===="  return (q? :example : :normal  )  end
		if str == "****"  return (q? :sidebar : :normal  )  end
		if str == "____"  return (q? :passage : :normal  )  end
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
			if block(line) == content[end].tag
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
				meta = { :group => group(line) }
				push!(content, DocNode(block(line),meta) )
				inblock = true
			end
		end
	end
	
	# Remove comments
	obj.content = filter(x -> isa(x,String) || x.tag != :comment, content)
end


# - - - - - - - - - - - + - - - - - - - - - - - #
#                S E C T I O N S                #
# - - - - - - - - - - - + - - - - - - - - - - - #
function parse_sections!(obj::DocNode, level::Integer=0)
	#
	# All sections begin with a (possibly empty) preamble.
	#
	content = Item[ DocNode(:preamble) ]
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
			push!(content, DocNode(:section,meta) )
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
			#
			# Allows you to start a document with == headings, but not lower.
			#
			if is(item, :section) || level == 0
				parse_sections!(item, level+1)
			end
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

