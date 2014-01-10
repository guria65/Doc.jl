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
== JDoc markup
"""
include("lib/parser.jl")

end
