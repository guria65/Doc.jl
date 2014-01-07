"""
:author: Daniel Carrera
:date:   2014-01-07

== Backend

The backend defines the contents of the global `DOC` object, and how the
`help()` and `apropos()` functions look inside that object. In this way,
the backend determines how the frontend macro--`@doc`--needs to populate
the `DOC` object.

`DOC` is a global dictionary of type `DocDict`. The keys are string
representations of functions, methods or other Julia objects. The values
are `DocEntry` objects which themselves are dictionaries, indexed by
symbols such as `:author`, `:date` and `:description`.
"""

export DOC, DocEntry, DocDict

import Base: help, apropos

typealias DocEntry Dict{Symbol,String}
typealias DocDict  Dict{String,DocEntry}

DOC = DocDict()


function apropos(s::Union(String,Regex))
	f(key)  = typeof(s) == Regex ? ismatch(s,key) : contains(key,s)
	matches = filter(f, keys(DOC))
	
	if length(matches) == 0
		return "There are no matches for '$s'"
	else
		return "Matches for '$s':\n\n    " * join(matches,"\n    ")
	end
end

help(m::String) = haskey(DOC,s) ? DOC[s][:description] : apropos(s)

# 
# See also: https://github.com/JuliaLang/julia/blob/master/base/methodshow.jl
#           xdump(Method)
#           xdump(m.func.code)
# 
function help(m::Method)
	fun = string(m.func.code.name)
	sig = match(r"^(\(.+\)) at .*\:\d+", string(m).captures[1])
	str = fun * sig # Ex: "foo" * "(x::Real)" == "foo(x::Real)"
	
	haskey(DOC,str) ? DOC[str][:description] : help(fun)
end

function help(f::Function)
	s = string(f)
	
	if haskey(DOC,s)
		DOC[s][:description]
	else
		# If we can identify a unique method, try to use that.
		ms = collect( methods(f) )
		length(ms) == 1 ? help(ms[1]) : apropos(s)
	end
end

