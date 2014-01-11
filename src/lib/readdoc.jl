
export readdoc

# 
# Extract docstrings given a file name.
# 
function readdoc(filename)
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
