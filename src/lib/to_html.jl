
doc"
=== to_html

Convert a parsed JDoc object into HTML.
"

export to_html

typealias Value Union(Number,String)

#
# Functions named after the object tag: $(tag)_to_html
#
to_html(val::Value) = string(val)
to_html(arr::Array) = join( map(to_html,arr) ,"\n" )
to_html(obj::JNode) = @eval $(symbol(string(obj.tag) * "_to_html"))( $(obj) )

#
# Nothing-to-do sections.
#
preamble_to_html(obj) = to_html(obj.content)

pass_to_html(obj) = join(obj.content, "\n")


#
# Sections
#
function section_to_html(obj)
	
	title = obj.meta[:title]
	hx = "h$(obj.meta[:level] + 1)"
	id = replace(lowercase(title), " ", "_")
	
	html = "<$hx id='$id'>$title</$hx>\n"
	
	if obj.meta[:level] == 0 && haskey(obj.meta, :author)
		html *= "<p><strong>Author:</strong> " * obj.meta[:author]
		
		if haskey(obj.meta, :revision)
			html *= "<br/><strong>Revision:</strong> " * obj.meta[:revision]
		end
		
		html *= "</p>\n"
	end
	
	return html * to_html(obj.content)
end

#
# Root node
#
function root_to_html(obj)
	#
	# Do we have a level 0 heading, author, and revision?
	#
	head = ""
	child = obj.content[1]
	if child.tag == :section && child.meta[:level] == 0
		title = child.meta[:title]
		head *= "  <title>$title</title>\n"
		head *= "  <meta name='DC.Title' content='$title'/>\n"
		
		if haskey(child.meta,:author)
			author = child.meta[:author]
			head *= "  <meta name='DC.Creator' content='$author'/>\n"
			head *= "  <meta name='Author' content='$author'/>\n"
		end
		
		if haskey(child.meta,:revision)
			revision = child.meta[:revision]
			head *= "  <meta name='Revision' content='$revision'/>\n"
		end
	end
	head = "<head>\n" * head * "</head>\n"
	
	return	"""
			<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
			\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
			$head
			<html xmlns=\"http://www.w3.org/1999/xhtml\">
			$( to_html(obj.content) )
			</html>
			"""
end

#
# Normal blocks
#
function normal_to_html(obj)
	class = string(obj.tag)
	"\n<div class='$class'>\n" * to_html(obj.content) * "\n</div>\n"
end
example_to_html = normal_to_html
sidebar_to_html = normal_to_html
passage_to_html = normal_to_html

#
# Verbatim blocks
#
function verbatim_to_html(obj)
	class = string(obj.tag)
	"\n<pre class='$class'>\n" * to_html(obj.content) * "\n</pre>\n"
end
literal_to_html = verbatim_to_html
listing_to_html = verbatim_to_html

#
# Tables -- TODO -- For now, just print verbatim.
#
table_to_html = verbatim_to_html