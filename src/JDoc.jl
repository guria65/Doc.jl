"""
:author: Daniel Carrera
:date:   2014-01-09

= JDoc.jl

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
