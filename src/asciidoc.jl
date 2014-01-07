doc"""
:author: Daniel Carrera
:date:   2014-01-07

== Asciidoc implementation

...
"""

export @doc, @doc_str, @doc_mstr

macro doc_str(s)   init(s)   end
macro doc_mstr(s)  init(s)   end

macro doc(s,f)
	str = string(typeof(s) == Expr ? eval(s) : s) # Docstring.
	fun = string(typeof(f) == Expr ? eval(f) : f) # Function name.
	
	DOC[fun] = init(str)
end


#
# Creates a DocEntry object and pulls out the metadata.
# 
# -- Next step is to parse entry[:description] as Asciidoc.
#
function init(str)
	entry = DocEntry()
	entry[:docstring] = str
	entry[:description] = ""
	
	# Helpers.
	ismeta,    meta    = false, r"^:(\w+):\s*"
	isliteral, literal = false, r"^----"
	
	# Read the docstring line-by-line.
	for line in split(str,"\n")
		
		# Skip literal blocks.
		ismeta = false
		if isliteral
			# Test for the end of the litral block.
			isliteral = !ismatch(literal, line)
		else
			if ismatch(meta, line)
				key = match(meta,line).captures[1]
				val = replace(line,meta,"")
				entry[symbol(key)] = val
				ismeta = true
			elseif ismatch(literal, line)
				isliteral = true
			end
		end
		entry[:description] *= ismeta ? "" : line * "\n"
	end
	
	return entry
end

