
doc"
=== to_tree

Convert a parsed JDoc object into a string, formatted as a s-expression.
"

export to_tree

to_tree(val::Number,indent=0) = string(val)
to_tree(str::String,indent=0) = "\"$str\""
to_tree(sym::Symbol,indent=0) = ":" * string(sym)
to_tree(tpl::Tuple ,indent=0) = "(" * join(map(to_tree,tpl)," ") * ")"
to_tree(dic::Dict  ,indent=0) = join(map(to_tree,dic)," ")

function to_tree(arr::Array,indent=0)
	
	sp = " "^indent
	
	sp * join(map(x -> to_tree(x,indent),arr),"\n"*sp)
end

function to_tree(obj::DocNode,indent=0)
	
	sp = " "^indent
	
	str  =      "($(obj.tag) \n"
	str *= sp * "  (meta " * to_tree(obj.meta) * ")\n"
	str *= sp * "  (content \n" * to_tree(obj.content, indent+4) * "))"
	
	return str
end

