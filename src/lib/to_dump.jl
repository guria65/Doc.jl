
to_dump(val::Number,indent=0) = string(val)
to_dump(str::String,indent=0) = "\"$str\""
to_dump(sym::Symbol,indent=0) = ":" * string(sym)
to_dump(tpl::Tuple ,indent=0) = "(" * join(map(to_dump,tpl)," ") * ")"
to_dump(dic::Dict  ,indent=0) = join(map(to_dump,dic)," ")

function to_dump(arr::Array,indent=0)
	
	sp = " "^indent
	
	sp * join(map(x -> to_dump(x,indent),arr),"\n"*sp)
end

function to_dump(obj::DocNode,indent=0)
	
	sp = " "^indent
	
	str  =      "($(obj.tag) \n"
	str *= length(obj.meta) == 0  ? "" : sp * "  (meta " * to_dump(obj.meta) * ")\n"
	str *= to_dump(obj.content, indent+2) * ")"
	
	return str
end

