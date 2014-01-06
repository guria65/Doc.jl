doc"""
:author: Daniel Carrera
:date:   2014-01-06

== Base API

The basic API consists of a global `DOC` dictionary object.
The keys are the string representation of functions and
methods, and the values are DocEntry objects.
"""

export DOC

#
# TODO: Define `DocEntry` and `DocDict` correctly.
#
DocEntry = Dict{Symbol,String}
DocDict  = Dict{Any,DocEntry}

DOC = DocDict()

function help(key)
	DOC[ string(key) ][:description]
end
