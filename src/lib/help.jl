doc"
=== Online help

Use to `@doc` macro to add entries to the online help. You can use `@doc`
to document methods, functions, constants, and other Julia objects.

----
@doc \"About method foo(x::Int) ...\" function foo(x::Int) ... end
@doc \"About method foo(x::Real) ...\" foo(x::Real) = ...
@doc \"About object foo ...\" foo
----

==== backend

The documentation is stored in a global dictionary object called `DOC`.
The `help()` function looks up values inside `DOC`. You should not modify
`DOC` directly unless you know what you are doing. The keys are arbitrary
Julia objects and the values are dictionaries. The main documentation
should be in `DOC[obj][:doc]`.
"

import Base: help

typealias DocEntry Dict{Any,Any}
typealias DocDict  Dict{Any,DocEntry}

DOC = DocDict()

jhelp(key) = show(haskey(DOC,key) ? DOC[key][:doc] : "No help for `$key`")


macro doc(s,e)
	
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

