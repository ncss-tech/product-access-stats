##
##
##

library(plyr) # round_any()
library(reshape2)
library(sf)
library(spData) 
library(terra)

## local functions
source('../local-functions.R')

## common configuration
source('config.R')

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

## make grids

# WSS AOI
x <- readRDS(file.path(.input, 'AOI-points.rds'))

# ~ 
system.time(.makeGrids(x, .prefix = 'AOI-', .output = .gridOutput))


## check
z <- rast('../../GIS/WSS/AOI-density-HI.tif')
plot(z)



