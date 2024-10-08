.PR_DensityMap <- function(r, .file, .title, .g, .pal = 'blues3', .rev = TRUE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE, breaks = 20)
  
  png(filename = .file, width = 2400, height = 1200, res = 200)
  
  plot(
    r,
    col = hcl.colors(n = 100, palette = .pal, rev = .rev),
    legend = FALSE,
    axes = FALSE,
    mar = c(2, 1, 1, 1),
    maxcell = ncell(r) + 1,
    main = .title
  )
  lines(pr, lwd = 2)
  
  mtext(sprintf('counts / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), side = 1, line = 2.5, adj = 0.7)
  
  par(fig = c(0.01, 0.55, 0.06, 0.29), new = TRUE, mar = c(0, 0, 0, 0), xpd = NA) 
  
  plot(h, col = hcl.colors(n = length(h$breaks), pal = .pal, rev = .rev), axes = FALSE, xlab = '', ylab = '', main = '')
  
  .lab <- quantile(r[], probs = c(0, 0.1, 0.3, 0.5, 0.75, 0.95, 0.99, 0.999, 1), na.rm = TRUE)
  .lab <- unique(.lab)
  .lab <- round(.lab)
  
  
  
  .usr <- par('usr')
  .offset <- .usr[3] + (.usr[3] * 0.85)
  points(h$mids, rep(.offset, times = length(h$mids)), pch = 15, col = hcl.colors(n = length(h$mids), pal = .pal, rev = .rev), cex = 2)
  
  # TODO use plyr::round_any() on "large" numbers
  
  .at <- log(pmax(.lab, 1), base = 10)
  axis(side = 1, at = .at, labels = .lab, cex.axis = 0.95, padj = -1.5, line = 0.85, tick = FALSE)
  
  dev.off()
  
  resizeImage(.file, geom = '1000x')
  
}


.HI_DensityMap <- function(r, .file, .title, .g, .pal = 'blues3', .rev = TRUE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE, breaks = 20)
  
  ## grid + overlay of HI
  png(filename = .file, width = 1900, height = 1500, res = 200)
  
  plot(
    log(r, base = 10),
    col = hcl.colors(n = 100, palette = .pal, rev = .rev),
    legend = FALSE,
    axes = FALSE,
    mar = c(1.5, 1, 1, 1),
    maxcell = ncell(r) + 1,
    main = .title
  )
  
  lines(hi, lwd = 2)
  
  mtext(sprintf('counts / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), side = 1, line = 2.5, adj = 0.7)
  
  par(fig = c(0.01, 0.55, 0.06, 0.29), new = TRUE, mar = c(0, 0, 0, 0), xpd = NA) 
  
  plot(h, col = hcl.colors(n = length(h$breaks), pal = .pal, rev = .rev), axes = FALSE, xlab = '', ylab = '', main = '')
  
  .lab <- quantile(r[], probs = c(0, 0.1, 0.3, 0.5, 0.75, 0.95, 0.99, 0.999, 1), na.rm = TRUE)
  .lab <- unique(.lab)
  .lab <- round(.lab)
  
  
  
  .usr <- par('usr')
  .offset <- .usr[3] + (.usr[3] * 0.85)
  points(h$mids, rep(.offset, times = length(h$mids)), pch = 15, col = hcl.colors(n = length(h$mids), pal = .pal, rev = .rev), cex = 2)
  
  # TODO use plyr::round_any() on "large" numbers
  
  .at <- log(pmax(.lab, 1), base = 10)
  axis(side = 1, at = .at, labels = .lab, cex.axis = 0.95, padj = -1.5, line = 0.85, tick = FALSE)
  
  
  dev.off()
  
  resizeImage(.file, geom = '800x')
  
}

.AK_DensityMap <- function(r, .file, .title, .g, .pal = 'oslo', .rev = FALSE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE, breaks = 20)
  
  ## grid + overlay of AK
  png(filename = .file, width = 2200, height = 1700, res = 200)
  
  plot(
    log(r, base = 10),
    col = hcl.colors(n = 100, palette = .pal, rev = .rev),
    legend = FALSE,
    axes = FALSE,
    mar = c(1.5, 1, 1, 1),
    maxcell = ncell(r) + 1,
    main = .title
  )
  
  lines(ak, lwd = 1)
  
  mtext(sprintf('counts / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), side = 1, line = 2.5, adj = 0.7)
  
  par(fig = c(0.01, 0.55, 0.06, 0.29), new = TRUE, mar = c(0, 0, 0, 0), xpd = NA) 
  
  plot(h, col = hcl.colors(n = length(h$breaks), pal = .pal, rev = .rev), axes = FALSE, xlab = '', ylab = '', main = '')
  
  .lab <- quantile(r[], probs = c(0, 0.1, 0.3, 0.5, 0.75, 0.95, 0.99, 0.999, 1), na.rm = TRUE)
  .lab <- unique(.lab)
  .lab <- round(.lab)
  
  
  .usr <- par('usr')
  .offset <- .usr[3] + (.usr[3] * 0.85)
  points(h$mids, rep(.offset, times = length(h$mids)), pch = 15, col = hcl.colors(n = length(h$mids), pal = .pal, rev = .rev), cex = 2)
  
  # TODO use plyr::round_any() on "large" numbers
  
  .at <- log(pmax(.lab, 1), base = 10)
  axis(side = 1, at = .at, labels = .lab, cex.axis = 0.95, padj = -1.5, line = 0.85, tick = FALSE)
  
  
  dev.off()
  
  resizeImage(.file, geom = '800x')
  
}


.CONUS_DensityMap <- function(r, .file, .title, .g, .pal = 'mako', .rev = TRUE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # get CONUS extent and expand by ~ 100km = 100,000m
  b <- ext(us_states)
  x.lim <- c(b[1] - 1e5, b[2] + 1e5)
  y.lim <- c(b[3] - 1e5, b[4] + 1e5)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE)
  
  # TODO: consider adjusting y-scale to prevent low-frequency values from being squished
  # h$counts <- log(h$counts, base = 10)
  
  png(filename = .file, width = 2200, height = 1600, res = 200)
  
  plot(
    log(r, base = 10),
    col = hcl.colors(n = 100, palette = .pal, rev = .rev),
    legend = FALSE,
    axes = FALSE,
    mar = c(3, 1, 1.5, 0.5),
    maxcell = ncell(r) + 1,
    main = '',
    ylim = y.lim,
    xlim = x.lim
  )
  
  title(.title, line = 1)
  
  lines(us_states, lwd = 2)
  
  mtext(sprintf('counts / %sx%s km grid cell\nUpdated: %s', as.character(.g), as.character(.g), u.date), side = 1, line = 2.2, adj = 0.7)
  
  par(fig = c(0.01, 0.55, 0.06, 0.29), new = TRUE, mar = c(0, 0, 0, 0), xpd = NA) 
  
  plot(h, col = hcl.colors(n = length(h$breaks), pal = .pal, rev = .rev), axes = FALSE, xlab = '', ylab = '', main = '')
  
  .lab <- quantile(r[], probs = c(0, 0.1, 0.3, 0.5, 0.75, 0.95, 0.99, 0.999, 1), na.rm = TRUE)
  .lab <- unique(.lab)
  .lab <- round(.lab)
  
  
  
  .usr <- par('usr')
  .offset <- .usr[3] + (.usr[3] * 0.85)
  points(h$mids, rep(.offset, times = length(h$mids)), pch = 15, col = hcl.colors(n = length(h$mids), pal = .pal, rev = .rev), cex = 2)
  
  # TODO use plyr::round_any() on "large" numbers
  
  .at <- log(pmax(.lab, 1), base = 10)
  axis(side = 1, at = .at, labels = .lab, cex.axis = 0.95, padj = -1.5, line = 0.85, tick = FALSE)
  
  
  dev.off()
  
  resizeImage(.file, geom = '1000x')
  
}




# NOTE: many vars taken from global environment
# NOTE: WSS data are close to requiring postGIS
# TODO: finish implementing AK processing

.makeGrids <- function(x, .prefix, .output) {
  
  ## upgrade to spatVect
  # GCS WGS84
  message('  txt -> spatVect')
  x <- vect(x, geom = c('x', 'y'), crs = 'EPSG:4326')
  
  
  ## filter: CONUS, AK, HI, PR
  # TODO: make this more efficient (slowest component)
  # TODO: AK, HI, OR: only intersect missing records from CONUS
  message('  spatial intersection/filter')
  x.conus <- intersect(x, us_states)
  
  ## 2023-10-03: auto-transform seems to have been dropped from terra
  ##            -> consider performing intersection in GCS
  ## exclude CONUS for efficiency
  .idx <- which(! x$LogID %in% x.conus$LogID)
  x.hi <- intersect(x[.idx, ], hi)
  x.pr <- intersect(x[.idx, ], pr)
  x.ak <- intersect(x[.idx, ], ak)
  
  
  ## transform CONUS points / outline to 5070
  message('  transform to local CRS')
  x.conus <- project(x.conus, crs.conus)
  us_states <- project(us_states, crs.conus)
  
  ## transform AK, HI, PR points / MLRA
  x.pr <- project(x.pr, crs.pr)
  pr <- project(pr, crs.pr)
  
  x.hi <- project(x.hi, crs.hi)
  hi <- project(hi, crs.hi)
  
  x.ak <- project(x.ak, crs.ak)
  ak <- project(ak, crs.ak)
  
  
  # TODO: dynamic file path
  ## keep CONUS points for later
  message('  save CONUS points (EPSG:5070) for later')
  .file <- sprintf("processed-data/%s-points-AEA.Rds", .prefix)
  saveRDS(x.conus, file = .file)
  
  ## convert points -> grid of counts, at specified resolution
  # note rasterize() trick
  message('  point -> grid conversion')
  
  ## downgrade spatVect -> data.frame
  # currently a bug in split.terra
  x.conus <- as.data.frame(x.conus[, c('date', 'ym')], geom = 'xy')
  
  # split to list, for iteration over year-month chunks
  x.conus <- split(x.conus, x.conus$ym)
  gc(reset = TRUE)
  
  ## iterate over year-month chunks, just CONUS
  .chunkNames <- sort(names(x.conus))
  
  # empty spatRast template for density grids
  .template <- rast(ext(ext.conus), res = 1000 * g.conus, crs = crs.conus, vals = NA_integer_)
  
  .chunks <- map(x.conus, .progress = TRUE, .f = function(i) {
    
    # init temp spatVect for this iteration, much faster than subsetting a giant spatVect
    .v <- vect(i, geom = c('x', 'y'), crs = crs.conus)
    
    # gridded density over template spatRast
    .res <- rasterize(.v, .template, background = NA, fun = function(j){length(j)})
    
    names(.res) <- .v$ym[1]
    return(.res)
    
  })
  
  # list -> multi-band spatRast
  .chunks <- rast(.chunks)
  
  ## TODO: ensure ordering through time is correct!
  
  ## TODO: save metadata
  
  
  # totals for HI and PR
  .template <- rast(ext(ext.hi), res = 1000 * g.hi, crs = crs.hi, vals = NA_integer_)
  r.hi <- rasterize(x.hi, .template, background = NA, fun = function(i){length(i)})
  
  .template <- rast(ext(ext.pr), res = 1000 * g.pr, crs = crs.pr, vals = NA_integer_)
  r.pr <- rasterize(x.pr, .template, background = NA, fun = function(i){length(i)})
  
  .template <- rast(ext(ext.ak), res = 1000 * g.ak, crs = crs.ak, vals = NA_integer_)
  r.ak <- rasterize(x.ak, .template, background = NA, fun = function(i){length(i)})
  
  
  # flatten slices -> total
  r.conus <- app(.chunks, fun = sum, na.rm = TRUE)
  
  # TODO make monthly mean grids
  
  
  ## file names
  f.conus <- file.path(
    .output, 
    sprintf("%s-density.tif", .prefix)
  )
  
  f.conus.stack <- file.path(
    .output, 
    sprintf("%s-stack-density.tif", .prefix)
  )
  
  f.pr <- file.path(
    .output, 
    sprintf("%s-density-PR.tif", .prefix)
  )
  
  f.hi <- file.path(
    .output, 
    sprintf("%s-density-HI.tif", .prefix)
  )
  
  f.ak <- file.path(
    .output, 
    sprintf("%s-density-AK.tif", .prefix)
  )
  
  ## save for GIS use
  writeRaster(r.conus, filename = f.conus, datatype = "INT2U", overwrite = TRUE)
  writeRaster(.chunks, filename = f.conus.stack, datatype = "INT2U", overwrite = TRUE)
  
  writeRaster(r.pr, filename = f.pr, datatype = "INT2U", overwrite = TRUE)
  writeRaster(r.hi, filename = f.hi, datatype = "INT2U", overwrite = TRUE)
  writeRaster(r.ak, filename = f.ak, datatype = "INT2U", overwrite = TRUE)
  
}

resizeImage <- function(f, geom) {
  i <- image_read(f)
  i <- image_resize(i, geometry = geom, filter = 'LanczosSharp')
  image_write(i, path = f)
}


## replaced by rasterize() in modern terra
# 
# pts2grid <- function(p, g) {
#   stop()
#   # down-grade to DF
#   # this will fail with 0-length spatVect
#   x.df <- as.data.frame(p, geom = 'XY')
#   
#   # decimate coordinates grid cell spacing (km) -> (m)
#   x.df$x <- round_any(x.df$x, g * 1000)
#   x.df$y <- round_any(x.df$y, g * 1000)
#   
#   ## cast to wide format and count occurrences
#   # fake column for counting
#   x.df$fake <- 'counts'
#   x.wide <- dcast(x.df, x + y ~ fake, fun.aggregate = length, value.var = 'fake')
#   
#   ## points -> rast
#   # use CRS of points
#   r <- rast(x.wide, type = 'xyz', crs = crs(p))
#   
#   # # crop to CONUS
#   # r <- crop(r, ext(us_states))
#   
#   ## TODO: figure this out: not all NA are 0
#   # NA -> zero density
#   # r[is.na(r[])] <- 0.0001 
#   
#   return(r)
# }


