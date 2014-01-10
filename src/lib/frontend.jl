"""

=== Frontend

The frontend provides the `@doc` macro, and nothing more. The job of `@doc`
is to populate the global `DOC` object correctly, so that the `help()` and
`apropos()` functions will behave correctly.

==== Usage of `@doc` macro

@doc '...' function foo(x::Real) ... end
@doc '...' macro foo(x::Real) ... end
@doc '...' foo(x::Real) = ...
@doc '...' foo

==== AsciiDoc

The only AsciiDoc-dependant part of this module is the interpretation of
literal blocks in the `newdoc()` function.

TOO: Rewrite `newdoc` with a call to the JDoc parser, or similar.

"""

export @doc

# 
# :( function foo(x::Real) 3x end ).args[1] == :( foo(x::Real) )
# :( foo(x::Real)  = 3x + x^2 - 4 ).args[1] == :( foo(x::Real) )
# :( foo )                                  == :foo
# 
macro doc(s,f)
	if typeof(f) == Expr # Expr -> Method Name
		key = string(f.args[1])
		key = key[3:end-1] # Remove the surounding ":(" and ")"
		eval(f)
	else
		key = string(f)  # Symbol -> Function Name
	end
	
	docstr   = typeof(s) == Expr ? eval(s) : s
	DOC[key] = newdoc(docstr)
end


#
# Creates a DocEntry object and pulls out the metadata.
# 
# -- Next step is to parse entry[:description] as Asciidoc.
#
function newdoc(str)
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

