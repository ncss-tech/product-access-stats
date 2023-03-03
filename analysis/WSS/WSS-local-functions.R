
evalDensity <- function(x, g) {
  
  # CRS defs
  crs_lower48 <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
  
  # convert to SPDF
  coordinates(x) <- ~ x + y
  proj4string(x) <- '+proj=longlat +datum=WGS84'
  
  # transform to CONUS CRS
  x <- spTransform(x, CRS(crs_lower48))
  
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
  
  return(r)
}


# x: raw data
# g: grid spacing, km
# ~ 40 sq. mi. -> 10,180m grid cells --> 10km x 10km is about right
plotDensity <- function(x, g=10) {
  
  # current time slice 
  u.date <- x$ym[1]
  
  r <- evalDensity(x, g=g)
  
  ## TODO: figure this out: not all NA are 0
  # NA -> zero density
  # r[is.na(r[])] <- 0.0001 
  
  # get a bbox for CONUS and expand by 100km = 100,000m
  b <- bbox(us_states)
  x.lim <- c(b[1, 1] - 1e5, b[1, 2] + 1e5)
  y.lim <- c(b[2, 1] - 1e5, b[2, 2] + 1e5)
  
  
  # grid + overlay of CONUS states
  # maxpixels argument used to ensure all cells are included = slower plotting
  pp <- levelplot(r, maxpixels=ncell(r) + 1,
                  margin=FALSE, xlim=x.lim, ylim=y.lim,
                  scales=list(draw=FALSE), zscaleLog=10,
                  col.regions=viridis,
                  panel=function(...) {
                    panel.levelplot(...)
                    sp.polygons(us_states, col='black', lwd=2)
                  }
  )
  
  
  
  # png(file='WSS-AOI-density.png', width=1100, height=1100, res = 100, type = 'cairo', antialias = 'subpixel')
  
  update(pp, 
         main=sprintf('Web Soil Survey AOI Centroid Density\n%s', u.date), 
         sub=sprintf('log10(counts) / %sx%s km grid cell', as.character(g), as.character(g)), 
         scales=list(cex=1.125)
  )
  
  # dev.off()
  
  
}
