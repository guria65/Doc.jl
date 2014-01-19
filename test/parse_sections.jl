#
# Article doctype => No level-0 subsections allowed.
#
docstr = """
Hello

= My Title
"""
@test_throws docdoc(docstr) # No text allowed before a level-0 section.

docstr = """
= Title 1

= Title 2
"""
@test_throws docdoc(docstr) # Only one level-0 section allowed.

#
# Test metadata
#
docstr = """
= Title
Daniel Carrera
v1.0.13

Hello
"""
@test docdoc(docstr).content[1].meta[:level] == 0
@test docdoc(docstr).content[1].meta[:title] == "Title"
@test docdoc(docstr).content[1].meta[:author] == "Daniel Carrera"
@test docdoc(docstr).content[1].meta[:revision] == "v1.0.13"

docstr = """
= Title

Hello
"""
@test_throws docdoc(docstr).content[1].meta[:author] # No author.

docstr = """
= Title
Daniel Carrera

Hello
"""
@test_throws docdoc(docstr).content[1].meta[:revision] # No revision.

#
# Nesting levels.
#
docstr = """
= Title

Preamble

== Section 1

=== Subsetion 1.1

==== Subsection 1.1.1

== Section 2
"""
obj = docdoc(docstr)
top = obj.content[1]

@test obj.tag == :root

@test top.meta[:level] == 0
@test top.content[1].tag == :preamble
@test top.content[2].tag == :section
@test top.content[3].tag == :section

@test top.content[2].meta[:level] == 1
@test top.content[3].meta[:level] == 1

@test top.content[2].content[1].tag == :section
@test top.content[2].content[1].meta[:level] == 2
@test top.content[2].content[1].meta[:title] == "Subsetion 1.1"

@test top.content[2].content[1].content[1].tag == :section
@test top.content[2].content[1].content[1].meta[:level] == 3
@test top.content[2].content[1].content[1].meta[:title] == "Subsection 1.1.1"


