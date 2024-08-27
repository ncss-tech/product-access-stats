##
##
##

library(sf)
library(spData) 
library(terra)
library(magick)
library(purrr)
library(av)


## local functions
source('../local-functions.R')

## configuration
# global
source('../../analysis/global-config.R')
# local
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
ak <- project(ak, crs.ak)

## load metadata
.metadata <- readRDS('metadata.rds')
.dateRange <- paste(.metadata$dateRange, collapse = ' \U2192 ')


## WSS AOI
.prefix <- 'AOI'
.title <- sprintf('WSS AOI Centroid Density\n%s', .dateRange)


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

# AK
r <- rast(file.path(.gridOutput, sprintf("%s-density-AK.tif", .prefix)))
.of <- file.path(.figureOutput, sprintf('%s-density-AK.png', .prefix))
.AK_DensityMap(r, .file = .of, .title = .title, .g = g.ak)


# TODO: monthly CONUS


# time slices for CONUS
r <- rast(file.path(.gridOutput, sprintf("%s-stack-density.tif", .prefix)))
nm <- names(r)

.td <- file.path(.figureOutput, 'animation')
dir.create(.td)

# ~3 minutes
walk(seq_along(nm), .progress = TRUE, .f = function(i) {
  .of <- file.path(.td, sprintf('%s-density-%03d.png', .prefix, i))
  
  .title <- sprintf('WSS AOI Centroid Density\n%s', nm[i])
  
  .CONUS_DensityMap(r[[i]], .file = .of, .title = .title, .g = g.conus)
})


# animate

# encode as MP4 ~ 4FPS
f.render <- list.files(.td, pattern = '.png$', full.names = TRUE)
av_encode_video(
  input = f.render, 
  output = file.path(.figureOutput, 'AOI-animation.mp4'), 
  framerate = 4,
  # required if image height is not an even number
  vfilter = "pad=ceil(iw/2)*2:ceil(ih/2)*2"
)

unlink(.td, recursive = TRUE)


## cleanup
rm(list = ls())
gc(reset = TRUE)




