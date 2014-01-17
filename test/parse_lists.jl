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


#
#  INDENTATION -- Should be flattened.
#
#---------------------------------------

docstr = """
* Hello
    * World
    * Platypus
* Kangaroo
Canada
* Koala
"""
list = jdoc(docstr).content[1]

@test list.tag == :bullet
@test length(list.content) == 5
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[3].tag == :listitem
@test list.content[4].tag == :listitem
@test list.content[5].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[3].content[1].tag == :para
@test list.content[4].content[1].tag == :para
@test list.content[5].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Hello"
@test list.content[2].content[1].content[1] == "World"
@test list.content[3].content[1].content[1] == "Platypus"
@test list.content[4].content[1].content[1] == "Kangaroo"
@test list.content[4].content[1].content[2] == "Canada"
@test list.content[5].content[1].content[1] == "Koala"

docstr = """
1. Hello
    1. World
    2. Platypus
2. Kangaroo
Canada
3. Koala
"""
list = jdoc(docstr).content[1]

@test list.tag == :ordered
@test length(list.content) == 5
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[3].tag == :listitem
@test list.content[4].tag == :listitem
@test list.content[5].tag == :listitem
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[3].content[1].tag == :para
@test list.content[4].content[1].tag == :para
@test list.content[5].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Hello"
@test list.content[2].content[1].content[1] == "World"
@test list.content[3].content[1].content[1] == "Platypus"
@test list.content[4].content[1].content[1] == "Kangaroo"
@test list.content[4].content[1].content[2] == "Canada"
@test list.content[5].content[1].content[1] == "Koala"

docstr = """
Name:: Joe
    Title:: CEO
        Salary:: $1
Country:: Canada
North America
Sex:: Male
"""
list = jdoc(docstr).content[1]

@test list.tag == :definition
@test length(list.content) == 5
@test list.content[1].tag == :listitem
@test list.content[2].tag == :listitem
@test list.content[3].tag == :listitem
@test list.content[4].tag == :listitem
@test list.content[5].tag == :listitem
@test list.content[1].meta[:term] == "Name"
@test list.content[2].meta[:term] == "Title"
@test list.content[3].meta[:term] == "Salary"
@test list.content[4].meta[:term] == "Country"
@test list.content[5].meta[:term] == "Sex"
@test list.content[1].content[1].tag == :para
@test list.content[2].content[1].tag == :para
@test list.content[3].content[1].tag == :para
@test list.content[4].content[1].tag == :para
@test list.content[5].content[1].tag == :para
@test list.content[1].content[1].content[1] == "Joe"
@test list.content[2].content[1].content[1] == "CEO"
@test list.content[3].content[1].content[1] == "$1"
@test list.content[4].content[1].content[1] == "Canada"
@test list.content[4].content[1].content[2] == "North America"
@test list.content[5].content[1].content[1] == "Male"



