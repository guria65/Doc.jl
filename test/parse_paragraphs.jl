#
#  BASIC FEATURES
#
#---------------------------------------

docstr = """
This is paragraph 1.
This is part of paragraph 1.

This is paragraph 2.
This is part of paragraph 2.
"""
obj = docdoc(docstr)

@test obj.content[2] == ""
@test obj.content[1].tag == :para
@test obj.content[3].tag == :para
@test obj.content[1].content[1] == "This is paragraph 1."
@test obj.content[1].content[2] == "This is part of paragraph 1."


docstr = """
TIP: This is a tip.
This is part of the tip.
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :tip
@test obj.content[1] == "This is a tip."
@test obj.content[2] == "This is part of the tip."


docstr = """
NOTE: This is a note.
This is part of the note.
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :note
@test obj.content[1] == "This is a note."
@test obj.content[2] == "This is part of the note."


docstr = """
WARNING: This is a warning.
This is part of the warning.
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :warning
@test obj.content[1] == "This is a warning."
@test obj.content[2] == "This is part of the warning."


docstr = """
CAUTION: This is a caution.
This is part of the caution.
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :caution
@test obj.content[1] == "This is a caution."
@test obj.content[2] == "This is part of the caution."


docstr = """
IMPORTANT: This is important.
This is part of the important message.
"""
obj = docdoc(docstr).content[1]

@test obj.tag == :important
@test obj.content[1] == "This is important."
@test obj.content[2] == "This is part of the important message."


#
#  NESTING WITHIN SECTIONS
#
#---------------------------------------

docstr = """
== This is a heading

This is a paragraph.

TIP: This is a tip.

NOTE: This is a note.

WARNING: This is a warning.

CAUTION: This is a caution.

IMPORTANT: This is important.
"""
obj = docdoc(docstr)

@test obj.content[1].tag == :section
@test obj.content[1].content[1] == ""
@test obj.content[1].content[2].tag == :para
@test obj.content[1].content[2].content[1] == "This is a paragraph."
@test obj.content[1].content[3] == ""
@test obj.content[1].content[4].tag == :tip
@test obj.content[1].content[4].content[1] == "This is a tip."
@test obj.content[1].content[5] == ""
@test obj.content[1].content[6].tag == :note
@test obj.content[1].content[6].content[1] == "This is a note."
@test obj.content[1].content[7] == ""
@test obj.content[1].content[8].tag == :warning
@test obj.content[1].content[8].content[1] == "This is a warning."
@test obj.content[1].content[9] == ""
@test obj.content[1].content[10].tag == :caution
@test obj.content[1].content[10].content[1] == "This is a caution."
@test obj.content[1].content[11] == ""
@test obj.content[1].content[12].tag == :important
@test obj.content[1].content[12].content[1] == "This is important."

