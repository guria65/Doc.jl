#
#  BASIC FEATURES
#
#---------------------------------------

#
# Basic bullet lists.
#
docstr = """
* Item 1
* Item 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :bullet
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Item 1"
@test list.content[2].content[1].content[1] == "Item 2"

docstr = """
- Item 1
- Item 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :bullet
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Item 1"
@test list.content[2].content[1].content[1] == "Item 2"


#
# Basic ordered lists.
#
docstr = """
. Item 1
. Item 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :ordered
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Item 1"
@test list.content[2].content[1].content[1] == "Item 2"

docstr = """
1. Item 1
1. Item 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :ordered
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Item 1"
@test list.content[2].content[1].content[1] == "Item 2"

docstr = """
1. Item 1
2. Item 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :ordered
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Item 1"
@test list.content[2].content[1].content[1] == "Item 2"


#
# Basic definition lists.
#
docstr = """
Term 1:: Definition 1
Term 2:: Definition 2
"""
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[1].meta[:term] == "Term 1"
@test list.content[2].meta[:term] == "Term 2"
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Definition 1"
@test list.content[2].content[1].content[1] == "Definition 2"


docstr = "Hello::World"
list = jdoc(docstr).content[1]

@test list.tag == :para
@test list.content[1] == "Hello::World"


docstr = "Hello:: World"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "World"


docstr = "Hello :: World"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "World"


docstr = "Hello(x::Int, y:: Real)::World"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello(x::Int, y"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Real)::World"


docstr = "Hello(x::Int, y::Real):: World::Water"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello(x::Int, y::Real)"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "World::Water"


docstr = "Hello(x::Int, y::Real):: World:: Water"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello(x::Int, y::Real):: World"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Water"


docstr = "Hello(x:: Int, y::Real):: World::Water"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello(x:: Int, y::Real)"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "World::Water"


docstr = "Hello(x:: Int, y::Real):: World:: Water"
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test list.content[1].tag == :listitem
@test list.content[1].meta[:term] == "Hello(x:: Int, y::Real):: World"
@test list.content[1].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Water"


