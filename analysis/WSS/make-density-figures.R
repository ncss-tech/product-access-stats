##
##
##


library(sp)
library(latticeExtra)
library(rasterVis)
library(viridisLite)
library(sf)
library(spData) 
library(terra)
library(magick)

## local functions
source('../local-functions.R')

## common configuration
source('config.R')

## date stamp 
u.date <- as.character(Sys.Date())

## PR outline, GCS
pr <- vect(file.path(.outlines, 'MLRA52-PR.shp'))

## HI outline, GCS
hi <- vect(file.path(.outlines, 'MLRA52-HI.shp'))

## AK outline, GCS
ak <- vect(file.path(.outlines, 'MLRA52-AK.shp'))

## us state outlines for CONUS
data("us_states")
us_states <- vect(us_states)

## transform outlines
us_states <- project(us_states, crs.conus)

# local CRS for AK, HI, PR
pr <- project(pr, crs.pr)
hi <- project(hi, crs.hi)
# TODO AK


## WSS AOI
.prefix <- 'AOI'
.title <- 'WSS AOI Centroid Density'

# CONUS
r <- rast(file.path(.gridOutput, sprintf("%s-density.tif", .prefix)))
.of <- file.path(.figureOutput, sprintf('%s-density.png', .prefix))
.CONUS_DensityMap(r, .file = .of, .title = .title, .g = g.conus)

# HI
r <- rast(file.path(.gridOutput, sprintf("%s-density-HI.tif", .prefix)))
.of <- file.path(.figureOutput, sprintf('%s-density-HI.png', .prefix))
.HI_DensityMap(r, .file = .of, .title = .title, .g = g.hi)

# PR
r <- rast(file.path(.gridOutput, sprintf("%s-density-PR.tif", .prefix)))
.of <- file.path(.figureOutput, sprintf('%s-density-PR.png', .prefix))
.PR_DensityMap(r, .file = .of, .title = .title, .g = g.pr)


# TODO AK




