library(latticeExtra)
# library(tactile)
library(reshape2)
library(data.table)
library(ragg)

# load combined/pre-processed data
x <- readRDS(file.path(wd, 'data', 'AOI-points.rds'))

# lots of records
nrow(x)

## hits / day
x <- data.table(x)
x.daily <- x[, .(freq = .N), by = .(date)]
x.daily <- as.data.frame(x.daily)

nrow(x.daily)
range(x.daily$date)

## TODO: automate this
# smooth over ... what
x.ts <- ts(x.daily$freq, frequency = 30, start = c(2015, 04, 01))

# STL decomposition
x.stl <- stl(x.ts, s.window = 'periodic')
# plot(x.stl)

# re-make for simpler plotting
d <- as.data.frame(x.stl$time.series)
d$date <- x.daily$date
d$raw <- x.daily$freq
names(d) <- c('Seasonal', 'Trend', 'Remainder', 'date', 'Raw Data')


m <- reshape2::melt(d, id.vars = 'date', measure.vars = c('Trend', 'Raw Data'))

# last updated 
u.date <- as.character(max(x.daily$date, na.rm=TRUE))


## this is a bit of a hack--works best when data end on the first day of the next month

# labels for x-axis
d.seq <- seq.Date(from = min(x.daily$date), to = max(x.daily$date), by='6 months')
d.seq <- c(d.seq, max(x.daily$date) + 1)

## figure
p <- xyplot(
  value ~ date | variable, 
  data = m, 
  main = paste('Web Soil Survey: updated',  u.date), 
  sub = 'Timeseries Decomposition by STL (1 month period)', 
  type = 'l',
  xlim = c(min(d.seq) - 15, max(d.seq) + 15),
  layout = c(1, 2), 
  scales =list(
    alternating = 3, 
    x = list(
      at = d.seq, 
      format = '%b\n%Y'
    ), 
    y = list(
      relation = 'free', 
      rot = 0, 
      tick.number = 8
    )
  ), 
  # par.settings = tactile.theme(),
  col = 'royalblue', lwd = 1.5, 
  strip = strip.custom(bg = grey(0.90)), 
  ylab = 'AOI Created per Day', xlab = '', 
  panel = function(...) {
    panel.abline(v = d.seq, col = 1, lty = 3)
    panel.grid(h = -1, v = FALSE, col = 1, lty = 3)
    panel.xyplot(...)
  })

filename <- '../../results/WSS/WSS_AOI_daily-ts-decomposition.png'
agg_png(filename = filename, width = 1800, height = 800, res = 100, scaling = 1.5)
print(p)
dev.off()


