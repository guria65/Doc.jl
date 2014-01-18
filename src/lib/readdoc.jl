
export readdoc

# 
# Extract docstrings given a file name.
# 
readdoc(filename::String) = readdoc(open(filename))

# 
# Extract docstrings given an IOStream.
# 
function readdoc(io::IOStream)
	str = join(readlines(io) ,"")  # File contents.
	doc = "" # Docstring.
	pos = 0  # Position.
	
	const N = length(str)
	
	while pos < N
		(expr, pos) = parse(str, pos)
		
		doc *= expr2doc(expr)
	end
	
	return doc
end

isdoc(expr::Expr) = (expr.head == :macrocall) &&
                    (expr.args[1] == symbol("@doc_str")) ||
                    (expr.args[1] == symbol("@doc_mstr"))

isinclude(expr::Expr) = (expr.head == :call) &&
                        (expr.args[1] == :include)

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
