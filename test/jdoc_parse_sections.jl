#
# Article doctype => No level-0 subsections allowed.
#
docstr = """
Hello

= My Title
"""
@test_throws JDoc.parse_jdoc(docstr) # No text allowed before a level-0 section.

docstr = """
= Title 1

= Title 2
"""
@test_throws JDoc.parse_jdoc(docstr) # Only one level-0 section allowed.

#
# Test metadata
#
docstr = """
= Title
Daniel Carrera
v1.0.13

Hello
"""
@test JDoc.parse_jdoc(docstr).content[1].meta[:level] == 0
@test JDoc.parse_jdoc(docstr).content[1].meta[:title] == "Title"
@test JDoc.parse_jdoc(docstr).content[1].meta[:author] == "Daniel Carrera"
@test JDoc.parse_jdoc(docstr).content[1].meta[:revision] == "v1.0.13"

docstr = """
= Title

Hello
"""
@test_throws JDoc.parse_jdoc(docstr).content[1].meta[:author] # No author.

docstr = """
= Title
Daniel Carrera

Hello
"""
@test_throws JDoc.parse_jdoc(docstr).content[1].meta[:revision] # No revision.

