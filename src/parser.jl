doc"""
:author: Daniel Carrera
:date:   2014-01-06

== Parser

...
"""

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

