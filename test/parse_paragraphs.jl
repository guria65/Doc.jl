
docstr = """
This is paragraph 1.
This is part of paragraph 1.

This is paragraph 2.
This is part of paragraph 2.
"""
obj = jdoc(docstr)

@test obj.content[2] == ""
@test obj.content[1].tag == :para
@test obj.content[3].tag == :para
@test obj.content[1].content[1] == "This is paragraph 1."
@test obj.content[1].content[2] == "This is part of paragraph 1."


docstr = """
TIP: This is a tip.
This is part of the tip.
"""
obj = jdoc(docstr).content[1]

@test obj.tag == :tip
@test obj.content[1] == "This is a tip."
@test obj.content[2] == "This is part of the tip."


docstr = """
NOTE: This is a note.
This is part of the note.
"""
obj = jdoc(docstr).content[1]

@test obj.tag == :note
@test obj.content[1] == "This is a note."
@test obj.content[2] == "This is part of the note."


docstr = """
WARNING: This is a warning.
This is part of the warning.
"""
obj = jdoc(docstr).content[1]

@test obj.tag == :warning
@test obj.content[1] == "This is a warning."
@test obj.content[2] == "This is part of the warning."


docstr = """
CAUTION: This is a caution.
This is part of the caution.
"""
obj = jdoc(docstr).content[1]

@test obj.tag == :caution
@test obj.content[1] == "This is a caution."
@test obj.content[2] == "This is part of the caution."


docstr = """
IMPORTANT: This is important.
This is part of the important message.
"""
obj = jdoc(docstr).content[1]

@test obj.tag == :important
@test obj.content[1] == "This is important."
@test obj.content[2] == "This is part of the important message."
