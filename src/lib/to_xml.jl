
#
# Functions named after the object tag: $(tag)_to_xml
#
to_xml(val::Value)   = string(val)
to_xml(arr::Array)   = join( map(to_xml,arr) ,"\n" )
to_xml(obj::DocNode) = @eval $(symbol(string(obj.tag) * "_to_xml"))( $(obj) )

#
# Nothing-to-do sections.
#
preamble_to_xml(obj) = to_xml(obj.content)

pass_to_xml(obj) = join(obj.content, "\n")

#
# Lists
#
function listitem_to_xml(obj)
	if haskey(obj.meta, :term)
		"""
		<varlistentry>
		  <term>$( obj.meta[:term] )</term>
		  <listitem>$( to_xml(obj.content) )</listitem>
		</varlistentry>
		"""
	else
		"<listitem>$( to_xml(obj.content) )</listitem>"
	end
end

variable_to_xml(obj) = "<variablelist>\n$( to_xml(obj.content) )\n</variablelist>\n"
itemized_to_xml(obj) = "<itemizedlist>\n$( to_xml(obj.content) )\n</itemizedlist>\n"
ordered_to_xml(obj)  = "<orderedlist> \n$( to_xml(obj.content) )\n</orderedlist>\n"

#
# Sections
#
function section_to_xml(obj)
	
	author   = haskey(obj.meta, :author)   ? obj.meta[:author]   : ""
	revision = haskey(obj.meta, :revision) ? obj.meta[:revision] : ""
	
	if obj.meta[:level] == 0
		"""
		<title>$( obj.meta[:title] )</title>
		<articleinfo>
		  <author>
		    $( author )
		  </author>
		  <date>
		    $( revision )
		  </date>
		</articleinfo>
		$( to_xml(obj.content) )
		"""
	else
		"""
		<section>
		  <title>$( obj.meta[:title] )</title>
		  $( to_xml(obj.content) )
		</section>
		"""
	end
end

#
# Root node
#
function root_to_xml(obj)
	"""
	<?xml version='1.0' encoding='UTF-8'?>
	<!DOCTYPE article PUBLIC '-//OASIS//DTD Simplified DocBook XML V1.0//EN'
	'http://www.oasis-open.org/docbook/xml/simple/1.0/sdocbook.dtd'>
	<article>
	  $( to_xml(obj.content) )
	</article>
	"""
end

#
# Paragraphs
#
general_xml(obj,tag) = "<$(tag)>\n$( to_xml(obj.content) )\n</$(tag)>\n"

tip_to_xml(obj)       = general_xml(obj, "tip")
para_to_xml(obj)      = general_xml(obj, "para")
note_to_xml(obj)      = general_xml(obj, "note")
warning_to_xml(obj)   = general_xml(obj, "warning")
caution_to_xml(obj)   = general_xml(obj, "caution")
example_to_xml(obj)   = general_xml(obj, "example")
sidebar_to_xml(obj)   = general_xml(obj, "sidebar")
passage_to_xml(obj)   = general_xml(obj, "blockquote")
important_to_xml(obj) = general_xml(obj, "important")

#
# Verbatim blocks
#
verbatim_xml(obj) = "<programlisting>\n$( to_xml(obj.content) )\n</programlisting>\n"

literal_to_xml = verbatim_xml
listing_to_xml = verbatim_xml

#
# Tables -- TODO -- For now, just print verbatim.
#
table_to_xml = verbatim_xml
