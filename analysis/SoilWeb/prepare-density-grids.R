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

# mobile app 2.x
x <- readRDS(file.path(.input, 'app-2x.Rds'))
.makeGrids(x, .prefix = 'app-2x', .output = .gridOutput)

# gmaps application
x <- readRDS(file.path(.input, 'gmap.Rds'))
.makeGrids(x, .prefix = 'gmap', .output = .gridOutput)


## check
# z <- rast('../../GIS/SoilWeb/app-2x-density-HI.tif')
# plot(z)



