
# 
# Extract docstrings given a file name.
# 
readdoc(filename::String) = readdoc(open(filename))

# 
# Extract docstrings given an IOStream.
# 
@doc "
Given an IO stream or file name, this function extracts
all the docstrings, respecting `include` directives.

" function readdoc(io::IOStream)
	#
	# FIXME: The "\n1" is an ugly hack to make sure the file ends in an expression.
	#
	str = join(readlines(io) ,"") * "\n1" # File contents.
	doc = "" # Docstring.
	pos = 0  # Position.
	
	const N = length(str)
	
	while pos < N
		#
		# Raise no errors -- Seems to be needed at the end of input.
		#
		expr, pos = parse(str, pos, raise=false)

		doc *= expr2doc(expr)
	end
	
	return doc
end

function isdoc(expr::Expr)
	
	expr.head != :macrocall && return false
	length(expr.args) == 0  && return false
	
    expr.args[1] == symbol("@doc_str")  && return true
    expr.args[1] == symbol("@doc_mstr") && return true
	
	return false
end
function isinclude(expr::Expr)
	
	expr.head != :call     && return false
	length(expr.args) == 0 && return false
	
	expr.args[1] == :include
end
    
expr2doc(other) = ""
function expr2doc(expr::Expr)
	if isdoc(expr)
		doc = "\n" * eval(expr)
	elseif isinclude(expr)
		doc = readdoc(expr.args[2])
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
