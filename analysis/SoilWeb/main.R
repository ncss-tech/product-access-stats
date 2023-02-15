##
##
##

## distill summaries of SoilWeb logs for further analysis
# ~ 2.5 minutes
source('prepare-data.R')


## create point density grids
# CONUS, PR, Hi
# ~ 6 minutes
source('prepare-density-grids.R')


## make density maps
# CONUS, PR, Hi
# ~ 2 minutes
source('make-density-figures.R')

## make time series plots
source('gmap-daily-ts-decomposition.R')

