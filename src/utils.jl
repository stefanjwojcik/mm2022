function agg(dat, cols, func)
	out = dat |> 
	(data -> groupby(data, cols)) |> 
	(data -> combine(data, Symbol.(names(data)) .=> func, renamecols=false))
    return out
end