module mm2022

##############################################################################
##
## Dependencies
##
##############################################################################

using CSV, DataFrames, Statistics, MLJ

##############################################################################
##
## Exported methods and types
##
##############################################################################

export  make_seeds,
        get_seed_submission_diffs,
        agg,
        eff_stat_seasonal_means,
        get_eff_tourney_diffs,
        get_eff_submission_diffs,
        Elo,
        elo_ranks,
        get_elo_tourney_diffs,
        get_elo_submission_diffs,
        make_momentum,
        make_momentum_sub,
        make_ranef_features,
        make_ranef_sub


##############################################################################
##
## Load files
##
##############################################################################

include("utils.jl")
include("efficiency.jl")
include("seeds.jl")
include("elo.jl")
include("momentum.jl")
#include("teameffects.jl")

end # module

