
typealias Value Union(Number,String)

#
# Functions named after the object tag: $(tag)_to_html
#
to_html(val::Value)   = string(val)
to_html(arr::Array)   = join( map(to_html,arr) ,"\n" )
to_html(obj::DocNode) = @eval $(symbol(string(obj.tag) * "_to_html"))( $(obj) )

#
# Nothing-to-do sections.
#
preamble_to_html(obj) = to_html(obj.content)

pass_to_html(obj) = join(obj.content, "\n")

#
# Lists
#
function listitem_to_html(obj)
	if haskey(obj.meta, :term)
		"""
		<dt>$( obj.meta[:term] )</dt>
		<dd>$( to_html(obj.content) )</dd>
		"""
	else
		"<li>$( to_html(obj.content) )</li>"
	end
end
variable_to_html(obj) = "<dl>\n" * to_html(obj.content) * "</dl>\n"
itemized_to_html(obj) = "<ul>\n" * to_html(obj.content) * "</ul>\n"
ordered_to_html(obj)  = "<ol>\n" * to_html(obj.content) * "</ol>\n"
	

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
	
	return	"""
			<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
			\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
			<head>
			<!-- Load MathJax securely via HTTPS -->
			<script type='text/javascript'
			  src='https://c328740.ssl.cf1.rackcdn.com/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'>
			</script>
			$head
			</head>
			<html xmlns=\"http://www.w3.org/1999/xhtml\">
			$( to_html(obj.content) )
			</html>
			"""
end

#
# Paragraphs and regular blocks.
#
para_to_html(obj) = "<p>$( to_html(obj.content) )</p>\n"

general_html_block(obj) = "<div class='$(obj.tag)'>$( to_html(obj.content) )</div>\n"

tip_to_html       = general_html_block
note_to_html      = general_html_block
warning_to_html   = general_html_block
caution_to_html   = general_html_block
important_to_html = general_html_block

example_to_html = general_html_block
sidebar_to_html = general_html_block
passage_to_html = general_html_block

#
# Verbatim blocks
#
function verbatim_html_block(obj)
	class = string(obj.tag)
	"\n<pre class='$class'>\n" * to_html(obj.content) * "\n</pre>\n"
end
literal_to_html = verbatim_html_block
listing_to_html = verbatim_html_block

#
# Tables -- TODO -- For now, just print verbatim.
#
table_to_html = verbatim_html_block
