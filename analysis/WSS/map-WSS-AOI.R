##
##
##

## stephen's examples
## https://smroecker.github.io/soil-pit/2019_creating_maps_with_R.html#25_usda-nass_corn_yield_data

library(sp)
library(rgdal)
library(rasterVis)
library(latticeExtra)
library(plyr)
library(reshape2)
library(rasterVis)
library(viridis)
library(sf)
library(spData) 


# TODO kernel density map
# library(spatialEco)
# s.dens <- sp.kde(x=s[x.idx, ], bw=4000, newdata=r.stack.30$forms, n=5000, standardize = TRUE, scale.factor = 10000)


# datestamp 
u.date <- as.character(Sys.Date())

# grid spacing, km
# ~ 40 sq. mi. -> 10,180m grid cells --> 10km x 10km is about right
g <- 10

# CRS defs
crs_lower48 <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

data("us_states")
us_states <- as(us_states, 'Spatial')
us_states <- spTransform(us_states, CRS(crs_lower48))

# load combined/pre-processed data
wd <- 'S:/NRCS/Archive_Dylan_Beaudette/NSSC/WSS-access-stats/'
x <- readRDS(file.path(wd, 'data', 'AOI-points.rds'))


# subset for prototyping
# x <- x[sample(1:nrow(x), 1000), ]

# TODO: filter: CONUS, AK, HI, PR

# convert to SPDF
coordinates(x) <- ~ x + y
proj4string(x) <- '+proj=longlat +datum=WGS84'

# transform to CONUS CRS
x <- spTransform(x, CRS(crs_lower48))

# keep SPDF for later
x.spdf <- x
saveRDS(x.spdf, file = file.path(wd, 'data', 'AOI-points-AEA.rds'))
rm(x.spdf); gc(reset = TRUE)

# down-grade to DF
x <- as(x, 'data.frame')

# decimate coordinates grid cell spacing (km) -> (m)
x$x <- round_any(x$x, g * 1000)
x$y <- round_any(x$y, g * 1000)

# fake colume for counting
x$fake <- 'counts'

# cast to wide format and count occurences
x.wide <- dcast(x, x + y ~ fake, fun.aggregate=length, value.var='fake')

# grid as sp::SpatialPixelsDataFrame
coordinates(x.wide) <- ~ x + y
proj4string(x.wide) <- crs_lower48
gridded(x.wide) <- TRUE

# convert to raster::raster
r <- raster(x.wide, layer=1)

# crop to CONUS
r <- crop(r, extent(us_states))

## TODO: figure this out: not all NA are 0
# NA -> zero density
# r[is.na(r[])] <- 0.0001 

# get a bbox for CONUS and expand by 100km = 100,000m
b <- bbox(us_states)
x.lim <- c(b[1, 1] - 1e5, b[1, 2] + 1e5)
y.lim <- c(b[2, 1] - 1e5, b[2, 2] + 1e5)


# grid + overlay of CONUS states
# maxpixels argument used to ensure all cells are included = slower plotting
pp <- levelplot(r, maxpixels = ncell(r) + 1,
          margin = FALSE, xlim = x.lim, ylim = y.lim,
          scales = list(draw = FALSE), zscaleLog = 10,
          col.regions = viridis,
          panel = function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col = 'black', lwd = 2)
          }
          )



png(file='../../results/WSS/WSS-AOI-density.png', width=1100, height=900, res = 100, type = 'cairo', antialias = 'subpixel')

update(pp, 
       main='Web Soil Survey AOI Centroid Density\n2015-2021', 
       sub=sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(g), as.character(g), u.date), 
       scales=list(cex=1.125)
       )

dev.off()


# save for GIS use
writeRaster(r, filename='../../GIS/WSS/AOI-density-2015-2021.tif', options="COMPRESS=LZW", datatype="INT2S", overwrite=TRUE)




