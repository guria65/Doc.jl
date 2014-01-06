doc"""
:author: Daniel Carrera
:date:   2014-01-06

== Macros

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
