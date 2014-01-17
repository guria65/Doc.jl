using Base.Test

include("../src/JDoc.jl")

using JDoc

tests = [ "parse_sections", "parse_paragraphs", "parse_blocks", "parse_lists" ]

for t in tests
    println("Running jdoc_$t ...")
    try
        include("$t.jl")
    catch err
        println()
        rethrow(err)
    end
end
println()
