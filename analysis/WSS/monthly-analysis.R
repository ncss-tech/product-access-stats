
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

source('local-functions.R')


# CRS defs
crs_lower48 <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

data("us_states")
us_states <- as(us_states, 'Spatial')
us_states <- spTransform(us_states, CRS(crs_lower48))

# load combined/pre-processed data
x <- readRDS(file.path(wd, 'data', 'AOI-points.rds')


xl <- split(x, x$ym)
rm(x)
gc(reset=TRUE)


plotDensity(xl[[12]])


# timestamp
u.date <- as.character(Sys.Date())

# grid spacing, km
# ~ 40 sq. mi. -> 10,180m grid cells --> 10km x 10km is about right
g <- 10


## TODO: convert to purrr/furrr
z <- lapply(xl, evalDensity, g = g)
names(z) <- names(xl)
z <- stack(z)


# get a bbox for CONUS and expand by 100km = 100,000m
b <- bbox(us_states)
x.lim <- c(b[1, 1] - 1e5, b[1, 2] + 1e5)
y.lim <- c(b[2, 1] - 1e5, b[2, 2] + 1e5)


## TODO: put these panels into a giant PDF / PNG

# png(file = 'WSS-AOI-density-by-month.png', width = 2400, height = 1200, antialias = 'cleartype')
# 
# levelplot(z, maxpixels=1e5,
#           margin=FALSE, xlim=x.lim, ylim=y.lim,
#           scales=list(draw=FALSE), zscaleLog=10,
#           col.regions=viridis,
#           panel=function(...) {
#             panel.levelplot(...)
#             sp.polygons(us_states, col='black', lwd=2)
#           }
# )
# 
# dev.off()

## TODO: animate with fixed z-scale

## highly skewed results...
# mean and sd over all year/months
z.mean <- stackApply(z, indices = rep(1, times=nlayers(z)), fun = mean)
z.sd <- stackApply(z, indices = rep(1, times=nlayers(z)), fun = sd)
z.cv <- z.sd / z.mean

par(mfcol = c(1, 3))
hist(log(z.mean))
hist(log(z.sd))
hist(log(z.cv))


# truncate for viz, why the high values... what do these represent?
z.mean[z.mean[] > 10] <- 10
z.sd[z.sd[] > 10] <- 10


z.cv[is.infinite(z.cv[])] <- NA
z.sd[z.sd[] < 0.1] <- NA


## monthly mean pretty interesting

png(file = '../../results/WSS/WSS-AOI-density-monthly-mean.png', width=1100, height=900, res = 100, type = 'cairo', antialias = 'subpixel')

p <- levelplot(z.mean,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE), zscaleLog=10,
          maxpixels = ncell(z.mean) + 1,
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)

p <- update(p, 
       main='Web Soil Survey AOI Centroid Density\nMean Monthly Values 2015-2021', 
       sub=sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(g), as.character(g), u.date), 
       scales=list(cex=1.125)
)

print(p)

dev.off()

# save for GIS use
writeRaster(z.mean, filename='../../GIS/WSS/AOI-density-mean-monthly.tif', options="COMPRESS=LZW", datatype="FLT4S", overwrite=TRUE)





levelplot(z.sd, maxpixels=1e5,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE), zscaleLog=10,
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)

levelplot(stack(z.mean, z.sd), maxpixels=1e5,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE), zscaleLog=10,
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)

levelplot(z.cv, maxpixels=1e5,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE),
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)

# simple change through time... ?
s <- z[[49]] - z[[1]]
# only positive changes for log10 scale
s[s[] < 0.1] <- NA

levelplot(s, maxpixels=1e5,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE),
          col.regions=viridis,
          zscaleLog = 10,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)


# 
# ## not interesting
# # ACF after 12 lags
# s <- stackApply(z, indices = rep(1, times=nlayers(z)), fun = function(i, na.rm=TRUE) {
#   if(all(is.na(i))) {
#     return(NA)
#   }
#   
#   a <- acf(na.omit(i), plot=FALSE, lag=12)
#   return(a$acf[13])
# })
# 
# 
# hist(s)
# hist(log(s))
# s[s[] < 0.001] <- NA
# 
# 
# levelplot(s, maxpixels=1e5,
#           margin=FALSE, xlim=x.lim, ylim=y.lim,
#           scales=list(draw=FALSE),
#           col.regions=viridis,
#           panel=function(...) {
#             panel.levelplot(...)
#             sp.polygons(us_states, col='black', lwd=2)
#           }
# )
# 
