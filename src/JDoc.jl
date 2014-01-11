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
include("lib/readdoc.jl")
include("lib/parser.jl")
include("lib/to_tree.jl")

end
