function agg(dat, cols, func)
	out = dat |> 
	(data -> groupby(data, cols)) |> 
	(data -> combine(data, Symbol.(names(data)) .=> func, renamecols=false))
    return out
end

# function to limit the submission sample only to men's teams
function get_mens_teams(submission_sample)
	# open men's team ids
	mens_teams = CSV.read("data/MTeams.csv", DataFrame).TeamID
	for row in eachrow(submission_sample)
		season, team1, team2 = parse.(Int, split(row.ID, "_"))
		if !(team1 in mens_teams) || !(team2 in mens_teams)
			row.ID = "0"
		end
	end
	return filter(row -> row.ID != "0", submission_sample)
end 

function impute_random(df, col, na=-99.0) 
	coltoimpute = df[!, col]
	coltoimpute[coltoimpute .== na] .= rand(coltoimpute[coltoimpute .!= na], sum(coltoimpute .== na))
	df[!, col] = coltoimpute
	return df
end
