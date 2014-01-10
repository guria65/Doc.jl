"""
= JDoc.jl
Daniel Carrera

Documentation system for Julia.
"""
module JDoc

"""
== Online help
"""
include("backend.jl")
include("frontend.jl")

"""
== JDoc markup
"""
include("parser.jl")

end
