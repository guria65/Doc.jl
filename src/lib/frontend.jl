doc"
=== Frontend

The frontend provides the `@jdoc` macro, and nothing more. The job of `@jdoc`
is to populate the global `DOC` object correctly, so that the `help()` and
`apropos()` functions will behave correctly.

==== Usage of `@jdoc` macro

@jdoc \"...\" function foo(x::Real) ... end
@jdoc \"...\" foo(x::Real) = ...
@jdoc \"...\" foo

"

export @jdoc

# 
# :( function foo(x::Real) 3x end ).args[1] == :( foo(x::Real) )
# :( foo(x::Real)  = 3x + x^2 - 4 ).args[1] == :( foo(x::Real) )
# :( foo )                                  == :foo
# 
macro jdoc(s,e)
	
	if typeof(e) == Expr
		# Expr => Get method
		
		#
		# e.head                   is  :(=) or :function
		# e.args[1]                is  :(foo(x,y::Real))
		# e.args[1].head           is  :call
		# e.args[1].args[1]        is  :foo
		# e.args[1].args[2:end]    is  [ :x , :(y::Real) ]
		#
		params = e.args[1].args[2:end]
		
		#
		# Get the signature as a tuple.
		#
		sig = map( x -> isa(x,Expr) ? x.args[2] : Any , params)
		sig = tuple(sig...)          # Convert [DataType,... ] -> (Symbol,...)
		sig = map(x -> eval(x), sig) # Convert (Symbol,...)    -> (DataType,...)
		
		#
		# Method list -- all methods that match the signature.
		#
		func = eval(e)  # Function.
		ml = methods(func, sig)
		ml = filter(m -> m.sig == sig, ml)
				
		#
		# The last man standing should be the correct method.
		#
		key = ml[1]
	else
		# Symbol => Get function
		
		key = eval(e)
	end
	
	docstr   = typeof(s) == Expr ? eval(s) : s
	DOC[key] = newdoc(docstr)
	
	#
	# Finally, run the function declaration.
	#
	:($(esc(e)))
end


#
# TODO: Parse the docstring and extract any metadata.
#
function newdoc(str)
	entry = DocEntry()
	entry[:doc] = str
	
	return entry
end

