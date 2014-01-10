"""

=== jdoc

This program extracts all the docstrings (i.e. triple-quoted
strings) out of a Julia file, respecting `include` directives.
Goals for the future include:

* Command-line `jdoc example.jl` program.

* `jdoc example.jl` should produce a pager similar to man pages or `perldoc`.

* Add some support for markup formats (e.g. Asciidoc, Markdown, ReST, LaTeX)
  using external programs.

* Add support for the `@doc` macro, implemented in the `Doc.jl` module.
"""

# 
# Extract docstrings given a file name.
# 
function file2doc(filename)
	io = open(filename)
	ln = readlines(io)
	
	close(io)
	
	str = join(ln ,"")  # File contents.
	doc = "" # Docstring.
	pos = 0  # Position.
	
	const N = length(str)
	
	while pos < N
		(expr, pos) = parse(str, pos)
		
		doc *= expr2doc(expr)
	end
	
	return doc
end

ismstr(expr::Expr) = (expr.head == :macrocall) &
                     (expr.args[1] == symbol("@mstr"))

isinclude(expr::Expr) = (expr.head == :call) &
                        (expr.args[1] == :include)

function expr2doc(expr::Expr)
	if ismstr(expr)
		# `eval` needed to run the @mstr macro.
		doc = eval(expr)
	elseif isinclude(expr)
		doc = file2doc(expr.args[2])
	else
		doc = ""
		for arg in expr.args
			if typeof(arg) == Expr
				doc *= expr2doc(arg)
			end
		end
	end
	
	return doc
end
