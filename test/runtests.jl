using Base.Test

include("../src/JDoc.jl")

using JDoc

tests = ["parse_sections"]

for t in tests
    println("Running jdoc_$t ...")
    try
        include("jdoc_$t.jl")
    catch err
        println()
        rethrow(err)
    end
end
println()
