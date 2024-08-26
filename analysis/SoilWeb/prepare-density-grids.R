##
##
##

library(reshape2)
library(sf)
library(spData) 
library(terra)
library(av)
library(purrr)


## local functions
source('../local-functions.R')

## configuration
# global
source('../../analysis/global-config.R')
# local
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
# ~ 5 minutes
x <- readRDS(file.path(.input, 'app-2x.Rds'))
x$LogID <- 1:nrow(x)
x$ym <- format(x$date, '%Y-%m')
.makeGrids(x, .prefix = 'app-2x', .output = .gridOutput)

# gmaps application
# ~ 10 minutes
x <- readRDS(file.path(.input, 'gmap.Rds'))
x$LogID <- 1:nrow(x)
x$ym <- format(x$date, '%Y-%m')
.makeGrids(x, .prefix = 'gmap', .output = .gridOutput)


## check
# z <- rast('../../GIS/SoilWeb/app-2x-density.tif')
# plot(z)

## cleanup
rm(list = ls())
gc(reset = TRUE)

