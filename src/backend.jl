"""
:author: Daniel Carrera
:date:   2014-01-07

== Base API

The basic API consists of a global `DOC` dictionary object.
The keys are the string representation of functions and
methods, and the values are DocEntry objects.
"""

export DOC

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

help(m::String) = haskey(DOC,s) ? DOC[s] : apropos(s)

# 
# See also: https://github.com/JuliaLang/julia/blob/master/base/methodshow.jl
#           xdump(Method)
#           xdump(m.func.code)
# 
function help(m::Method)
	fun = string(m.func.code.name)
	sig = match(r"^(\(.+\)) at .*\:\d+", string(m).captures[1])
	str = fun * sig # Ex: "foo" * "(x::Real)" == "foo(x::Real)"
	
	haskey(DOC,str) ? DOC[str] : help(fun)
end

function help(f::Function)
	s = string(f)
	
	if haskey(DOC,s)
		DOC[s]
	else
		# If we can identify a unique method, try to use that.
		ms = collect( methods(f) )
		length(ms) == 1 ? help(ms[1]) : apropos(s)
	end
end

