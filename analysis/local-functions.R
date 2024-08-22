.PR_DensityMap <- function(r, .file, .title, .g, .n = 10, .pal = 'blues3', .rev = TRUE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE, breaks = 20)
  
  png(filename = .file, width = 2200, height = 1200, res = 200)
  
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


.HI_DensityMap <- function(r, .file, .title, .g, .n = 10, .pal = 'blues3', .rev = TRUE) {
  
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


.CONUS_DensityMap <- function(r, .file, .title, .g, .n = 10, .pal = 'mako', .rev = TRUE) {
  
  # close device on error
  on.exit(try(dev.off(), silent = TRUE), add = TRUE)
  
  # get CONUS extent and expand by ~ 100km = 100,000m
  b <- ext(us_states)
  x.lim <- c(b[1] - 1e5, b[2] + 1e5)
  y.lim <- c(b[3] - 1e5, b[4] + 1e5)
  
  # histogram for legend
  h <- hist(log(r,  base = 10), plot = FALSE)
  
  png(filename = .file, width = 2200, height = 1600, res = 200)
  
  plot(
    log(r, base = 10),
    col = hcl.colors(n = 100, palette = .pal, rev = .rev),
    legend = FALSE,
    axes = FALSE,
    mar = c(3, 1, 1.5, 0.5),
    maxcell = ncell(r) + 1,
    main = .title,
    ylim = y.lim,
    xlim = x.lim
  )
  
  lines(us_states, lwd = 2)
  
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
  x.hi <- intersect(project(x[.idx, ], hi), hi)
  x.pr <- intersect(project(x[.idx, ], pr), pr)
  # x.ak <- intersect(x[.idx, ], ak)
  
  ## cleanup
  rm(x)
  gc(reset = TRUE)
  
  ## transform CONUS points / outline to 5070
  message('  transform to local CRS')
  x.conus <- project(x.conus, crs.conus)
  us_states <- project(us_states, crs.conus)
  
  ## transform AK, HI, PR points / MLRA
  x.pr <- project(x.pr, crs.pr)
  pr <- project(pr, crs.pr)
  
  x.hi <- project(x.hi, crs.hi)
  hi <- project(hi, crs.hi)
  
  # AK
  
  
  # TODO: dynamic file path
  ## keep CONUS points for later
  message('  save CONUS points (EPSG:5070) for later')
  .file <- sprintf("processed-data/%s-points-AEA.Rds", .prefix)
  saveRDS(x.conus, file = .file)
  
  
  ## convert points -> grid of counts, at specified resolution
  message('  point -> grid conversion')
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
  writeRaster(r.conus, filename = f.conus, datatype = "INT2U", overwrite = TRUE)
  writeRaster(r.pr, filename = f.pr, datatype = "INT2U", overwrite = TRUE)
  writeRaster(r.hi, filename = f.hi, datatype = "INT2U", overwrite = TRUE)
  
}

## TODO: wasteful copying / reshaping, can probably be done with grids only

pts2grid <- function(p, g) {
  # down-grade to DF
  # this will fail with 0-length spatVect
  x.df <- as.data.frame(p, geom = 'XY')
  
  # decimate coordinates grid cell spacing (km) -> (m)
  x.df$x <- round_any(x.df$x, g * 1000)
  x.df$y <- round_any(x.df$y, g * 1000)
  
  ## cast to wide format and count occurrences
  # fake column for counting
  x.df$fake <- 'counts'
  x.wide <- dcast(x.df, x + y ~ fake, fun.aggregate = length, value.var = 'fake')
  
  ## points -> rast
  # use CRS of points
  r <- rast(x.wide, type = 'xyz', crs = crs(p))
  
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
