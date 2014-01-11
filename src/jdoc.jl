"""

=== jdoc

WARNING: Work in progress.

This is a command-line program that extract all the docstrings out of
a Julia file (respecting `include` directives) to help produce manuals.
The program is a work in progress, but here is the intended API:

* `jdoc --raw` prints the unprocessed raw docstring. This allows users to
use an external program to process the docstring. Thus, users can use any
markup, like LaTeX, ReST or raw HTML.

* `jdoc` includes the *JDoc* markup format. JDoc is a subset of Asciidoc.
It is simpler, has a short learning curve, and is well suited for writing
program documentation. With it, `jdoc` can output other formats like HTML,
without requiring external programs.


This is how I intend `jdoc` to work:

----
jdoc example.jl         --  Pager, similar to man pages or perloc.
jdoc --raw  example.jl  --  Output raw docstring.
jdoc --html exampe.jl   --  Output HTML.
----

I also want to think about how `jdoc` should support the `@doc` macro
provided by the JDoc.jl module.

==== TOO

* Review the API so that the key features of the program can be
  accessed through the JDoc.jl module.
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
