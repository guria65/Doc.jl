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

docstr = """
= Title

Hello
"""
@test_throws JDoc.parse_jdoc(docstr).content[1].meta[:author] # No author.

#
# Test metadata
#
docstr = """
= Title
Daniel Carrera

Hello
"""
@test_throws JDoc.parse_jdoc(docstr).content[1].meta[:revision] # No revision.

