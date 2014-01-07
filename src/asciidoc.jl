doc"""
:author: Daniel Carrera
:date:   2014-01-07

== Asciidoc implementation

...
"""

export @doc, @doc_str, @doc_mstr

macro doc_str(s)   init(s)   end
macro doc_mstr(s)  init(s)   end

doc"""
=== Usage of `@doc` macro

@doc '...' function foo(x::Real) ... end
@doc '...' macro foo(x::Real) ... end
@doc '...' foo(x::Real) = ...
"""
# 
# :( function foo(x::Real) 3x end ).args[1] == :( foo(x::Real) )
# :( foo(x::Real)  = 3x + x^2 - 4 ).args[1] == :( foo(x::Real) )
# 
macro doc(s,f::Expr)
	#
	# NOTE: This macro only documents methods, not functions.
	#       I think that the `help` function needs to do a generic search.
	#
	docstr = typeof(s) == Expr ? eval(s) : s
	method = string( f.args[1] )
	
	DOC[method] = init(str)
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

