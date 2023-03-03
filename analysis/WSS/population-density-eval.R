library(raster)
library(sp)
library(hexbin)
library(latticeExtra)
library(viridis)


## AOI density, counts / 10x10 grid cells
r <- raster('../../GIS/WSS/AOI-density-2015-2021.tif')

# mean monthly version: that looks strange...
# r <- raster('AOI-density-mean-monthly.tif')

## population density CONUS only

# pop density grid
# Gridded Population of the World Version 3 (GPWv3): Population Density Grids.
# ds00g  population densities in 2000, unadjusted, persons per square km
pd <- raster('S:/NRCS/Archive_Dylan_Beaudette/SoilWeb/soilweb-vs-gridded-pop-density/usadens/usads00g/hdr.adf')

# quick comparison via sampling
s <- sampleRegular(r, 100000, sp=TRUE)
s$pd <- extract(pd, s)
s <- as.data.frame(s)
names(s) <- c('AOI_density', 'population_density', 'x', 'y')

# remove 0 for safe log-transform
s$population_density[s$population_density < 1] <- NA
s$AOI_density[s$AOI_density < 1] <- NA
s <- na.omit(s)

# for clarity, convert AOI density counts / 10x10 km -> counts / 1x1 km
s$AOI_density_1x1 <- s$AOI_density / 100

# 


png(file = '../../results/WSS/WSS-AOI-vs-popdens-hexbin.png', width=900, height=900, res = 120, type = 'windows', antialias = 'cleartype')

print(
  
  hexbinplot(AOI_density_1x1 ~ population_density, data=s, 
             scales=list(log=10, alternating=3), asp=1, xbins=60,
             main='Web Soil Survey AOI Centroid Density\n2015-2023',
             ylab='AOI Density (AOI / sq. km)',
             xlab='Population Density (person / sq. km)',
             colramp=viridis, trans=log, inv=exp, colorkey=FALSE,
             xscale.components=xscale.components.log10ticks, 
             yscale.components=yscale.components.log10ticks, 
             panel=function(...) {
               panel.hexbinplot(...)
               
               # add median
               m.x <- log(median(s$population_density, na.rm = TRUE), base = 10)
               m.y <- log(median(s$AOI_density_1x1, na.rm = TRUE), base = 10)
               panel.points(m.x, m.y, pch=4, col='firebrick', lwd=2)
               
               # reference points c/o wikipedia
               
               p.sf <- cbind(x = log(6658, base = 10), y = log(300, base = 10))
               panel.text(p.sf, label = 'San Francisco, CA', col = 'firebrick', cex = 0.66, font = 2)
               panel.text(p.sf, label = '\u2193', col = 'firebrick', cex = 1, font = 2, pos = 1)
               
               p.nc <- cbind(x = log(80.6, base = 10), y = log(300, base = 10))
               panel.text(p.nc, label = 'North Carolina', col = 'firebrick', cex = 0.66, font = 2)
               panel.text(p.nc, label = '\u2193', col = 'firebrick', cex = 1, font = 2, pos = 1)
               
               p.ne <- cbind(x = log(9.63, base = 10), y = log(300, base = 10))
               panel.text(p.ne, label = 'Nebraska', col = 'firebrick', cex = 0.66, font = 2)
               panel.text(p.ne, label = '\u2193', col = 'firebrick', cex = 1, font = 2, pos = 1)
               
               p.wy <- cbind(x = log(2.3, base = 10), y = log(300, base = 10))
               panel.text(p.wy, label = 'Wyoming', col = 'firebrick', cex = 0.66, font = 2)
               panel.text(p.wy, label = '\u2193', col = 'firebrick', cex = 1, font = 2, pos = 1)
             }
  )
)

dev.off()


## TODO: more realistic evaluation, use original points


## population density for > 50th pctile density
# ~ 111 AOI centroids / 10 x 10 km grid cell
idx <- which(s$AOI_density > median(s$AOI_density))

# remove missing data, convert to log base 10, compute density (smoothed frequency distribution)
d <- density(na.omit(log(s$population_density[idx], base=10)))


# convert to data.frame for plotting
d <- data.frame(x=d$x, y=d$y)

# plot, note trick used to fool lattice into re-computing log-scale x-axis
png(file='../../results/WSS/median-AOI-vs-popdens.png', width=800, height=600, res=100, type='windows', antialias='cleartype')

print(
  xyplot(y ~ 10^x, data=d, type=c('l', 'g'), main='Web Soil Survey\nAOI Centroid Density > 50th pctile\n2015-2023', xlab=list(cex=1.25, label='Population Density (person / sq. km)'), ylab='Relative Frequency', col='black', lwd=2, scales=list(cex=1, x=list(log=10)), xscale.components= xscale.components.logpower)
)

dev.off()


# 
# 
# ## AOI density / population density ?
# ## how do you interpret this?
# 
# library(sf)
# library(rgdal)
# library(spData) 
# library(rasterVis)
# 
# # crop / warp population density to CONUS extent in AEA
# e <- projectExtent(r, CRS(projection(pd)))
# pd.conus <- crop(pd, e)
# pd.conus <- projectRaster(pd.conus, r)
# 
# # ratio: AOI density (counts / km) vs. population density (persons / km)
# z <- (r / 100) / (pd.conus)
# 
# # replace divide by 0 errors
# z[which(is.infinite(z[]))] <- NA
# 
# # quick check: ok
# plot(z > 0.1)
# hist(log(z))
# 
# crs_lower48 <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
# 
# data("us_states")
# us_states <- as(us_states, 'Spatial')
# us_states <- spTransform(us_states, CRS(crs_lower48))
# 
# 
# levelplot(z, maxpixels=ncell(z) + 1,
#           margin=FALSE,
#           scales=list(draw=FALSE), zscaleLog=10,
#           col.regions=viridis,
#           panel=function(...) {
#             panel.levelplot(...)
#             sp.polygons(us_states, col='black', lwd=2)
#           }
# )
# 
# 
# 
# ## TODO: needs work...
# ## examples 
# 
# library(mapview)
# library(leafsync)
# 
# x.spdf <- readRDS(file = 'data/AOI-points-AEA.rds')
# 
# 
# # strip across CA, define in GCS
# e <- extent(-121, -119, 36, 37)
# e <- as(e, 'SpatialPolygons')
# proj4string(e) <- '+proj=longlat +datum=WGS84'
# # convert to CRS of AOI density map
# e <- spTransform(e, CRS(projection(r)))
# 
# 
# # crop data, neat this works for SPDF too
# r.tiny <- crop(r, e)
# x.spdf <- crop(x.spdf, e)
# pd.tiny <- crop(pd, spTransform(e, CRS('+proj=longlat +datum=WGS84')))
# 
# levelplot(r.tiny, scales=list(draw=FALSE), zscaleLog=10, margin=FALSE, col.regions=viridis)
# levelplot(pd.tiny, scales=list(draw=FALSE), zscaleLog=10, margin=FALSE, col.regions=viridis)
# 
# 
# m.1 <- mapview(r.tiny, col.regions=viridis, layer.name='AOI Density', map.types='OpenStreetMap')
# m.2 <- mapview(pd.tiny, col.regions=viridis, layer.name='Pop Density', map.types='OpenStreetMap')
# m.3 <- mapview(x.spdf, zcol='datenum', cex=0.25, layer.name='AOI Centroids', map.types='OpenStreetMap')
# 
# sync(m.1, m.2, m.3)
# 
# 

