##
##
##

## TODO: move to local disk



## data are stored locally for now
wd <- 'S:/NRCS/Archive_Dylan_Beaudette/NSSC/WSS-access-stats'


## re-build .csv.gz versions of the source data
## this has do be done manually, each file is slightly different
# source('process-raw-data-manually.R')


## prepare combined data
## automated
source('prepare-data.R')



## create point density grids
# CONUS, PR, Hi
# ~ 6 minutes
source('prepare-density-grids.R')


## AOI daily time-series analysis
source('AOI-daily-TS-evaluation.R')


## AOI density map
source('map-WSS-AOI.R')


## optional AOI by TLD
# source('prepare-TLD-data.R')
# source('map-WSS-AOI-by-TLD.R')


## population density evaluation
source('population-density-eval.R')


## monthly analysis: not finished
# source('monthly-analysis.R')





