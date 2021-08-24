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

# TLD defs
# https://uscupstate.libguides.com/c.php?g=257977&p=1721715


# datestamp 
u.date <- as.character(Sys.Date())

# grid spacing, km
# ~ 40 sq. mi. -> 10,180m grid cells --> 10km x 10km is about right
g <- 20

# CRS defs
crs_lower48 <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

data("us_states")
us_states <- as(us_states, 'Spatial')
us_states <- spTransform(us_states, CRS(crs_lower48))

# get a bbox for CONUS and expand by 100km = 100,000m
b <- bbox(us_states)
x.lim <- c(b[1, 1] - 1e5, b[1, 2] + 1e5)
y.lim <- c(b[2, 1] - 1e5, b[2, 2] + 1e5)


# load comined data
load('data/AOI-points-TLD.rda')

# get the top 7 or so
# ignore unknown
tab <- sort(table(x.tld$TLD), decreasing = TRUE)
tab <- tab[names(tab) != 'unknown']
tab <- tab[1:7]

# subset and set factor levels according to QTY
x <- x.tld[which(x.tld$TLD %in% names(tab)), ]
x$TLD <- factor(x$TLD, levels = names(tab))


# TODO: filter: CONUS, AK, HI, PR

# convert to SPDF
coordinates(x) <- ~ x + y
proj4string(x) <- '+proj=longlat +datum=WGS84'

# transform to CONUS CRS
x <- spTransform(x, CRS(crs_lower48))

# cleanup
rm(x.tld); gc(reset=TRUE)

# down-grade to DF
x <- as(x, 'data.frame')

# decimate coordinates grid cell spacing (km) -> (m)
x$x <- round_any(x$x, g * 1000)
x$y <- round_any(x$y, g * 1000)


# cast to wide format and count occurences of each TLD
# column order is based on factor levels --> rank
x.wide <- dcast(x, x + y ~ TLD, fun.aggregate=length, value.var='TLD')

# replace 0 -> NA
# required for log-transform
for(i in names(tab)) {
  x.wide[[i]][which(x.wide[[i]] == 0)] <- NA
}

# grid as sp::SpatialPixelsDataFrame
coordinates(x.wide) <- ~ x + y
proj4string(x.wide) <- crs_lower48
gridded(x.wide) <- TRUE

# convert to raster stack
r <- stack(x.wide)

# crop to CONUS
r <- crop(r, extent(us_states))

# select layers by index
layer.idx <- 1:6


# grid + overlay of CONUS states
# maxpixels argument used to ensure all cells are included = slower plotting
pp <- levelplot(r, layers=layer.idx,
                maxpixels=ncell(r) + 1,
                margin=FALSE, xlim=x.lim, ylim=y.lim,
                scales=list(draw=FALSE),
                zscaleLog=10,
                col.regions=viridis,
                panel=function(...) {
                  panel.levelplot(...)
                  sp.polygons(us_states, col='black', lwd=2)
                }
)


pp <- update(pp, 
             main='Web Soil Survey AOI Centroid Density\nOctober 2017 -- October 19', 
             sub=sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(g), as.character(g), u.date), 
             scales=list(cex=1.125)
)


## edit labels
## why doesn't this work 
# fancy.labels <- sprintf(".%s (%sk AOI)", names(tab), round(tab / 1000))
# row.names(pp) <- fancy.labels[layer.idx]



png(file='WSS-AOI-density-TLD.png', width=2800, height=1200, res = 100, type = 'cairo', antialias = 'subpixel')

print(pp)

dev.off()


# # save for GIS use
writeRaster(r, filename='AOI-density-TLD-FY18-19.tif', options="COMPRESS=LZW", datatype="INT2S", overwrite=TRUE)

# report top TLD counts
knitr::kable(t(tab))


## convert each to percentile scale
rn <- r
for(i in 1:nlayers(r)) {
  e <- ecdf(r[[i]][])
  rn[[i]] <- e(r[[i]][])
}

# copy names
names(rn) <- names(r)

# more appropriate colors
cols <- rev(RColorBrewer::brewer.pal(9, 'Spectral'))
cr <- colorRampPalette(cols)

pp.2 <- levelplot(rn, layers=layer.idx,
                maxpixels=ncell(r) + 1,
                margin=FALSE, xlim=x.lim, ylim=y.lim,
                scales=list(draw=FALSE),
                col.regions=cr,
                panel=function(...) {
                  panel.levelplot(...)
                  sp.polygons(us_states, col='black', lwd=2)
                }
)


pp.2 <- update(pp.2, 
             main='Web Soil Survey AOI Centroid Density\nOctober 2017 -- October 19', 
             sub=sprintf('Empirical Percentile(counts) / %sx%s km grid cell\nUpdated: %s', as.character(g), as.character(g), u.date), 
             scales=list(cex=1.125)
)


png(file='WSS-AOI-density-pctile-TLD.png', width=2800, height=1200, res = 100, type = 'cairo', antialias = 'subpixel')

print(pp.2)

dev.off()




## not sure if this is even useful
## Shannon entropy: all parties interested to the same degree?
# low values ---> one / two parties mostly interested
# high values ---> all equally interested

## method one: divide percentiles by number of layers and interpret as proportions
# this bungles NA
rn.prop <- rn / nlayers(rn)
se.pctile <- stackApply(rn.prop, indices=rep(1, times=nlayers(rn.prop)), fun=function(i, na.rm=TRUE) {
  aqp::shannonEntropy(i)
})


se.pctile[se.pctile == 0] <- NA

levelplot(se.pctile, maxpixels=ncell(se.pctile) + 1,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE),
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)          



## method two use raw counts
## there is a serious lack of balance here, maybe not ideal

# make a copy 
wd <- x.wide[, layer.idx]

# convert counts to proportions
wd@data <- sweep(wd@data, MARGIN = 1, STATS = rowSums(wd@data, na.rm = TRUE), FUN = '/')

# compute Shannon entropy
wd$se <- apply(wd@data, 1, aqp::shannonEntropy)

# looks reasonable
hist(wd$se)

# extract final layer, this is SE
se <- raster(wd, layer=length(layer.idx)+1)
se <- crop(se, extent(us_states))

# hmm.. hotspots are visible but very noisy
levelplot(se, maxpixels=ncell(se) + 1,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE),
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)          


## most-likely via percentiles... WTF?

ml <- stackApply(rn.prop, indices=rep(1, times=nlayers(rn.prop)), fun=function(i, na.rm=TRUE) {
  res <- which.max(i)
  if(length(res) == 0)
    res <- NA
  return(res)
})


levelplot(ml, maxpixels=ncell(se.pctile) + 1,
          margin=FALSE, xlim=x.lim, ylim=y.lim,
          scales=list(draw=FALSE),
          col.regions=viridis,
          panel=function(...) {
            panel.levelplot(...)
            sp.polygons(us_states, col='black', lwd=2)
          }
)          

