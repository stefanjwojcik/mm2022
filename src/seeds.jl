"""
This file is responsible for creating basic ncaa seeds and for creating the outcome 'result'
"""

function seed_to_int(seed::AbstractString)
	#Get just the digits from the seeding. Return as int
	parse(Int, seed[2:3])
end

#data_dir = '../input/'
function make_seeds(df_seeds, df_tour)

	df_seeds.seed_int = seed_to_int.(df_seeds.Seed)

	select!(df_seeds, Not(:Seed))
	select!(df_tour, Not([:DayNum, :WScore, :LScore, :WLoc, :NumOT]))

	print("creating seeds...")

	df_winseeds = copy(df_seeds)
	df_lossseeds = copy(df_seeds)

	rename!(df_winseeds, :TeamID => :WTeamID, :seed_int => :WSeed)
	rename!(df_lossseeds, :TeamID => :LTeamID, :seed_int => :LSeed)

	df_dummy = leftjoin(df_tour, df_winseeds, on = [:Season, :WTeamID])
	df_concat = innerjoin(df_dummy, df_lossseeds, on = [:Season, :LTeamID])
	df_concat.SeedDiff = df_concat.WSeed - df_concat.LSeed

	df_wins = copy(df_concat[:, [:Season, :WTeamID, :LTeamID, :SeedDiff]])
	df_wins.Result = repeat([1], nrow(df_wins))

	df_losses = copy(df_concat[:, [:Season, :WTeamID, :LTeamID]])
	df_losses.SeedDiff = df_concat.SeedDiff*-1
	df_losses.Result = repeat([0], nrow(df_wins))

	println("done")
	df_predictions = [df_wins; df_losses]
	return df_predictions
end

# returns the correct seed features for the submission sample
function get_seed_submission_diffs(submission_sample, seeds_df)
	#seed to int
	submission_sample.SeedDiff = repeat([-99.0], nrow(submission_sample))
	seeds_df.seed_int = seed_to_int.(seeds_df.Seed)
	@showprogress for row in eachrow(submission_sample)
		season, team1, team2 = parse.(Int, split(row.ID, "_"))
		# get seeds for team1 and team
		row1 = filter(row -> row[:Season] == season && row[:TeamID] == team1, seeds_df);
		row2 = filter(row -> row[:Season] == season && row[:TeamID] == team2, seeds_df);
		# if either team doesn't have a seed, insert a seed diff of -99, then go back and randomly impute
		if nrow(row1) == 0 || nrow(row2) == 0
			continue
		end
		submission_sample.SeedDiff[rownumber(row)] = (row1.seed_int - row2.seed_int)[1]
	end
	# for this with -99, impute randomly from the non-missing 
	submission_sample = impute_random(submission_sample, :SeedDiff)
	return submission_sample[:, [:SeedDiff]]
end
