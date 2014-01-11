
docstr = """
....
Literal line 1
Literal line 2
....
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :literal
@test obj.content[1].meta[:group] == :verbatim
@test obj.content[1].content[1] == "Literal line 1"
@test obj.content[1].content[2] == "Literal line 2"

docstr = """
----
Listing line 1
Listing line 2
----
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :listing
@test obj.content[1].meta[:group] == :verbatim
@test obj.content[1].content[1] == "Listing line 1"
@test obj.content[1].content[2] == "Listing line 2"

docstr = """
====
Example line 1
Example line 2
====
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :example
@test obj.content[1].meta[:group] == :normal  
@test obj.content[1].content[1] == "Example line 1"
@test obj.content[1].content[2] == "Example line 2"

docstr = """
****
Sidebar line 1
Sidebar line 2
****
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :sidebar
@test obj.content[1].meta[:group] == :normal  
@test obj.content[1].content[1] == "Sidebar line 1"
@test obj.content[1].content[2] == "Sidebar line 2"

docstr = """
____
Verse line 1
Verse line 2
____
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :verse  
@test obj.content[1].meta[:group] == :normal  
@test obj.content[1].content[1] == "Verse line 1"
@test obj.content[1].content[2] == "Verse line 2"

docstr = """
!===
Table line 1
Table line 2
!===
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :table  
@test obj.content[1].meta[:group] == :other   
@test obj.content[1].content[1] == "Table line 1"
@test obj.content[1].content[2] == "Table line 2"

docstr = """
++++
Pass line 1
Pass line 2
++++
"""
obj = parse_jdoc(docstr)

@test obj.content[1].tag == :block
@test obj.content[1].meta[:style] == :pass   
@test obj.content[1].meta[:group] == :other   
@test obj.content[1].content[1] == "Pass line 1"
@test obj.content[1].content[2] == "Pass line 2"

docstr = """
////
Comment line 1
Comment line 2
////
"""
obj = parse_jdoc(docstr)

@test obj.tag == :root
@test obj.content == []
