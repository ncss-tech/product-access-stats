.PR_DensityMap <- function(r, .file, .title, .g) {
  
  ### grid + overlay of PR
  # maxpixels argument used to ensure all cells are included = slower plotting
  pp <- levelplot(r, 
                  maxpixels = ncell(r) + 1,
                  margin = FALSE, 
                  # xlim = x.lim, ylim = y.lim,
                  scales = list(draw = FALSE), zscaleLog = 10,
                  col.regions = viridis,
                  panel = function(...) {
                    panel.levelplot(...)
                    sp.polygons(as(pr, 'Spatial'), col = 'black', lwd = 2)
                  }
  )
  
  
  pp <- update(pp, 
               main = .title, 
               sub = sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), 
               scales = list(cex=1.125)
  )
  
  
  png(filename = .file, width = 2200, height = 900, res = 200)
  
  print(pp)
  
  dev.off()
  
  resizeImage(.file, geom = '1000x')
  
}


.HI_DensityMap <- function(r, .file, .title, .g) {
  
  ## grid + overlay of HI
  # maxpixels argument used to ensure all cells are included = slower plotting
  pp <- levelplot(r, 
                  maxpixels = ncell(r) + 1,
                  margin = FALSE, 
                  # xlim = x.lim, ylim = y.lim,
                  scales = list(draw = FALSE), zscaleLog = 10,
                  col.regions = viridis,
                  panel = function(...) {
                    panel.levelplot(...)
                    sp.polygons(as(hi, 'Spatial'), col = 'black', lwd = 2)
                  }
  )
  
  
  pp <- update(pp, 
               main = .title, 
               sub = sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), 
               scales = list(cex=1.125)
  )
  
  png(filename = .file, width = 1900, height = 1500, res = 200)
  
  print(pp)
  
  dev.off()
  
  resizeImage(.file, geom = '800x')
  
}


.CONUS_DensityMap <- function(r, .file, .title, .g) {
  
  # get CONUS extent and expand by ~ 100km = 100,000m
  b <- ext(us_states)
  x.lim <- c(b[1] - 1e5, b[2] + 1e5)
  y.lim <- c(b[3] - 1e5, b[4] + 1e5)
  
  
  # grid + overlay of CONUS states
  # maxpixels argument used to ensure all cells are included = slower plotting
  pp <- levelplot(r, 
                  maxpixels = ncell(r) + 1,
                  margin = FALSE, 
                  xlim = x.lim, ylim = y.lim,
                  scales = list(draw = FALSE), zscaleLog = 10,
                  col.regions = viridis,
                  panel = function(...) {
                    panel.levelplot(...)
                    sp.polygons(as(us_states, 'Spatial'), col = 'black', lwd = 2)
                  }
  )
  
  pp <- update(pp, 
               main = .title, 
               sub = sprintf('log10(counts) / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), 
               scales = list(cex=1.125)
  )
  
  png(filename = .file, width = 2200, height = 1600, res = 200)
  
  print(pp)
  
  dev.off()
  
  resizeImage(.file, geom = '1000x')
  
}




## note: many vars taken from global environment

.makeGrids <- function(x, .prefix, .output) {
  
  ## upgrade to spatVect
  # GCS WGS84
  x <- vect(x, geom = c('x', 'y'), crs = 'EPSG:4326')
  
  
  ## filter: CONUS, AK, HI, PR
  x.conus <- intersect(x, us_states)
  x.ak <- intersect(x, ak)
  x.hi <- intersect(x, hi)
  x.pr <- intersect(x, pr)
  
  
  ## transform CONUS points / outline to 5070
  x.conus <- project(x.conus, crs.conus)
  us_states <- project(us_states, crs.conus)
  
  ## transform AK, HI, PR points / MLRA
  x.pr <- project(x.pr, crs.pr)
  pr <- project(pr, crs.pr)
  
  x.hi <- project(x.hi, crs.hi)
  hi <- project(hi, crs.hi)
  
  # AK
  
  
  
  ## TODO: dynamic file path
  ## keep CONUS points for later
  .file <- sprintf("processed-data/%s-points-AEA.Rds", .prefix)
  saveRDS(x.conus, file = .file)
  
  
  ## convert points -> grid of counts, at specified resolution
  r.conus <- pts2grid(x.conus, g = g.conus)
  r.pr <- pts2grid(x.pr, g = g.pr)
  r.hi <- pts2grid(x.hi, g = g.hi)
  
  ## file names
  f.conus <- file.path(
    .output, 
    sprintf("%s-density.tif", .prefix)
  )
  
  f.pr <- file.path(
    .output, 
    sprintf("%s-density-PR.tif", .prefix)
  )
  
  f.hi <- file.path(
    .output, 
    sprintf("%s-density-HI.tif", .prefix)
  )
  
  ## save for GIS use
  writeRaster(r.conus, filename = f.conus, datatype = "INT2S", overwrite = TRUE)
  writeRaster(r.pr, filename = f.pr, datatype = "INT2S", overwrite = TRUE)
  writeRaster(r.hi, filename = f.hi, datatype = "INT2S", overwrite = TRUE)
  
}


pts2grid <- function(p, g) {
  # down-grade to DF
  x.df <- as.data.frame(p, geom = 'XY')
  
  # decimate coordinates grid cell spacing (km) -> (m)
  x.df$x <- round_any(x.df$x, g * 1000)
  x.df$y <- round_any(x.df$y, g * 1000)
  
  ## cast to wide format and count occurrences
  # fake column for counting
  x.df$fake <- 'counts'
  x.wide <- dcast(x.df, x + y ~ fake, fun.aggregate = length, value.var = 'fake')
  
  ## points -> rast
  r <- rast(x.wide, type = 'xyz', crs = 'EPSG:5070')
  
  # # crop to CONUS
  # r <- crop(r, ext(us_states))
  
  ## TODO: figure this out: not all NA are 0
  # NA -> zero density
  # r[is.na(r[])] <- 0.0001 
  
  return(r)
}

resizeImage <- function(f, geom) {
  i <- image_read(f)
  i <- image_resize(i, geometry = geom, filter = 'LanczosSharp')
  image_write(i, path = f)
}
