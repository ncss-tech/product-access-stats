##
##
##

library(sf)
library(spData) 
library(terra)
library(purrr)


## local functions
source('../local-functions.R')

## configuration
# global
source('../../analysis/global-config.R')
# local
source('config.R')


## NOTE: must re-load all spatial data if re-gridding in the same R session

## PR outline, GCS
pr <- vect(file.path(.outlines, 'MLRA52-PR.shp'))

## HI outline, GCS
hi <- vect(file.path(.outlines, 'MLRA52-HI.shp'))

## AK outline, GCS
ak <- vect(file.path(.outlines, 'MLRA52-AK.shp'))

## us state outlines for CONUS
data("us_states")
us_states <- vect(us_states)
us_states <- project(us_states, 'EPSG:4326')


## load prepared log points
x <- readRDS(file.path(.input, 'AOI-points.rds'))


## save metadata
.metadata <- list(
  dateRange = range(x$date),
  nobs = nrow(x)
)

saveRDS(.metadata, 'metadata.rds')


## make grids
# ~ 33 seconds
system.time(.makeGrids(x, .prefix = 'AOI', .output = .gridOutput))

## cleanup
rm(x)
gc(reset = TRUE)


## check
# z <- rast('../../GIS/CART/AOI-density.tif')
# plot(z)



