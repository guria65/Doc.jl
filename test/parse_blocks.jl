docstr = """
////
Comment line 1
Comment line 2
////
"""
obj = docdoc(docstr)

@test obj.tag == :root
@test obj.content == []

docstr = """
|===
Table line 1
Table line 2
|===
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :table  
@test obj.meta[:group] == :other   
@test obj.content[1] == "Table line 1"
@test obj.content[2] == "Table line 2"

docstr = """
....
Literal line 1
Literal line 2
....
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :literal
@test obj.meta[:group] == :verbatim
@test obj.content[1] == "Literal line 1"
@test obj.content[2] == "Literal line 2"

docstr = """
----
Listing line 1
Listing line 2
----
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :listing
@test obj.meta[:group] == :verbatim
@test obj.content[1] == "Listing line 1"
@test obj.content[2] == "Listing line 2"

docstr = """
++++
Pass line 1
Pass line 2
++++
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :pass   
@test obj.meta[:group] == :other   
@test obj.content[1] == "Pass line 1"
@test obj.content[2] == "Pass line 2"

docstr = """
====
Example line 1
Example line 2
====
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :example
@test obj.meta[:group] == :normal  
@test obj.content[1].tag == :para
@test obj.content[1].content[1] == "Example line 1"
@test obj.content[1].content[2] == "Example line 2"

docstr = """
****
Sidebar line 1
Sidebar line 2
****
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :sidebar
@test obj.meta[:group] == :normal  
@test obj.content[1].tag == :para
@test obj.content[1].content[1] == "Sidebar line 1"
@test obj.content[1].content[2] == "Sidebar line 2"

docstr = """
____
Verse line 1
Verse line 2
____
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :passage  
@test obj.meta[:group] == :normal  
@test obj.content[1].tag == :para
@test obj.content[1].content[1] == "Verse line 1"
@test obj.content[1].content[2] == "Verse line 2"
