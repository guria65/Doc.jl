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
The `man()` function looks up values inside `DOC`. You should not modify
`DOC` directly unless you know what you are doing. The keys are arbitrary
Julia objects and the values are dictionaries. The main documentation
should be in `DOC[obj][:doc]`.
"

typealias DocEntry Dict{Any,Any}
typealias DocDict  Dict{Any,DocEntry}

DOC = DocDict()

import Base: fullname

#
# There is no fullname(Function) because a function's methods can be defined
# in different modules. All we can do is `fullname` all the methods.
#
function fullname(m::Method)
	md_name  = string(m.func.code.module)
	fn_name  = string(m.func.code.name)
	fn_param = match(r"^(\(.*\))", string(m) ).captures[1]
	
	return md_name * "." * fn_name * fn_param
end
#
# TODO: Update this so it also prints metadata, if any.
#
function printdoc(key;indent="")
	# Add indentation.
	doc = chomp(DOC[key][:doc])
	doc = indent * replace(doc, "\n", "\n$indent")
	print(doc)
end	

#
# Temporary name, to avoid lashes with `help()`.
#
function man(key::Method;quiet=false)
	
	println("\n  " * fullname(key))
	
	if haskey(DOC,key)
		printdoc(key, indent="    : ")
	elseif !quiet
		println("No help available.")
	end
end
function man(key::Function)
	
	println("Help for \"$(key)\":")
	
	if haskey(DOC,key)
		printdoc(key, indent="    ")
	end
	#
	# Even if no method is documented, this will at least give a list of methods.
	#
	for m in methods(key)
		man(m;quiet=true)
	end
end
function man(key::Module)
	#
	# TODO:
	#
	#  1.  Modify @doc_str and @doc_mstr so they insert the documentation
	#      in DOC[current_module()][:doc].
	# 
	#  2.  Modify @doc so it stores a list of methods that are documented
	#      in DOC[current_module()][:methods]
	#
	#  3.  Inside this function, print the module documentation followed by
	#      a list of functions that have methods documented.
	# 
	#  4.  Run names(Module) to at least get a list of names exported by
	#      the module.
end

#
# All other objects.
#
function man(key;quiet=false)
	# Determine the lineage of types.
	lineage = [typeof(val)]
	while lineage[end] != Any
		push!(lineage, super(lineage[end]))
	end
	lineage = join(lineage, " <: ")
	println("Type: $(lineage)\n")
	
	# See if we have documentation.
	if haskey(DOC,key)
		printdoc(key, indent="    : ")
	elseif !quiet
		println("No help available.")
	end
end

macro doc(args...)
	
	if length(args) < 2 || length(args) > 3
		error("Wrong number of arguments ($(length(args))) in @doc macro.")
	end
	
	if length(args) == 2
		meta = Dict()
		str  = args[1]
		expr = args[2]
	else
		meta = args[1]
		str  = args[2]
		expr = args[3]
	end
	
	if typeof(expr) == Expr
		# Expr => Get method
		
		#
		# expr.head                   is  :(=) or :function
		# expr.args[1]                is  :(foo(x,y::Real))
		# expr.args[1].head           is  :call
		# expr.args[1].args[1]        is  :foo
		# expr.args[1].args[2:end]    is  [ :x , :(y::Real) ]
		#
		params = expr.args[1].args[2:end]
		
		#
		# Get the signature as a tuple.
		#
		sig = map( x -> isa(x,Expr) ? x.args[2] : Any , params)
		sig = tuple(sig...)          # Convert [DataType,... ] -> (Symbol,...)
		sig = map(x -> eval(x), sig) # Convert (Symbol,...)    -> (DataType,...)
		
		#
		# Method list -- all methods that match the signature.
		#
		func = eval(expr)  # Function.
		ml = methods(func, sig)
		ml = filter(m -> m.sig == sig, ml)
		
		#
		# The last man standing should be the correct method.
		#
		key = ml[1]
	else
		# Symbol => Get function
		
		key = eval(expr)
	end
	
	DOC[key] = DocEntry()
	DOC[key][:doc]  = typeof(str) == Expr ? eval(str) : str
	DOC[key][:meta] = meta
	
	#
	# Finally, run the function declaration.
	#
	:($(esc(expr)))
end
