##
##
##

## distill summaries of SoilWeb logs for further analysis
# ~ 2.5 minutes
source('prepare-data.R')

## TODO: use better labeling for log scales

## create point density grids
# CONUS, PR, Hi, AK
# ~ 6 minutes
source('prepare-density-grids.R')


## make density maps
# CONUS, PR, Hi
# ~ 2 minutes
source('make-density-figures.R')

## make time series plots
source('gmap-daily-ts-decomposition.R')
source('app-2x-daily-ts-decomposition.R')


## TODO: old-style figures, land use intersection, etc.
