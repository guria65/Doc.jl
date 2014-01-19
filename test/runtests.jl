using Base.Test

include("../src/Doc.jl")

using Doc

tests = [ "parse_sections", "parse_paragraphs", "parse_blocks", "parse_lists" ]

for t in tests
    println("Running $t ...")
    try
        include("$t.jl")
    catch err
        println()
        rethrow(err)
    end
end
println()
