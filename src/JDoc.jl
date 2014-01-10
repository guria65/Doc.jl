"""
= JDoc.jl
Daniel Carrera

Documentation system for Julia.
"""
module JDoc

"""
== Online help
"""
include("lib/backend.jl")
include("lib/frontend.jl")

"""
== Writing manuals
"""
include("jdoc.jl")
include("lib/parser.jl")

end
