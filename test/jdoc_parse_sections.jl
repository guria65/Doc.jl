#
# Test error conditions.
#
docstr = """
Hello

= My Title
"""
@test_throws parse_jdoc(docstr) # No text allowed before a level-0 section.

docstr = """
= Title 1

= Title 2
"""
@test_throws parse_jdoc(docstr) # Only one top-level section allowed.

