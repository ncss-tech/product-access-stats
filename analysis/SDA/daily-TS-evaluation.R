library(latticeExtra)
library(tactile)
library(reshape2)
library(data.table)
library(ragg)
library(readr)

## common configuration
source('config.R')

# load combined/pre-processed data
x <- read_csv('E:/temp/SDA_baflogs_Metrics_Spatial_22_23_v3.csv')

# 2024: 10104148
nrow(x)


## hits / day

# DT is faster
x <- data.table(x)

# normalize name
x$date <- as.Date(x$log_date, format  = "%m-%d-%y")

# aggregate to day
x.daily <- x[, .(freq = .N), by = .(date)]
x.daily <- as.data.frame(x.daily)

nrow(x.daily)
range(x.daily$date)

# yearly stats
x.daily$yr <- format(x.daily$date, '%Y')

# monthly stats
x.daily$mo <- format(x.daily$date, '%b')
x.daily$mo <- factor(
  x.daily$mo, 
  levels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
)


## TODO: automate this
# smooth over ... 7-day window
x.ts <- ts(x.daily$freq, frequency = 7, start = c(2022, 03, 05))

# STL decomposition
x.stl <- stl(x.ts, s.window = 'periodic')
# plot(x.stl)

# re-make for simpler plotting
d <- as.data.frame(x.stl$time.series)
d$date <- x.daily$date
d$raw <- x.daily$freq
names(d) <- c('Seasonal', 'Trend', 'Remainder', 'date', 'Raw Data')

d$year <- as.integer(format(d$date, "%Y"))
d$doy <- as.integer(format(d$date, "%j"))
d$wkday <- factor((format(d$date, "%a")), levels = c('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'), ordered = TRUE)
d$month <- factor(format(d$date, "%b"), levels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))


m <- reshape2::melt(d, id.vars = c('date'), measure.vars = c('Trend', 'Raw Data'))

# last updated 
u.date <- as.character(max(x.daily$date, na.rm = TRUE))


## this is a bit of a hack--works best when data end on the first day of the next month

# labels for x-axis
d.seq <- seq.Date(from = min(x.daily$date), to = max(x.daily$date), by = '1 months')
# d.seq <- c(d.seq, max(x.daily$date) + 1)

## figure
p <- xyplot(
  value ~ date | variable, 
  data = m, 
  main = paste('Soil Data Access: updated',  u.date), 
  sub = 'Timeseries Decomposition (7-day period)', 
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
  ylab = 'Queries per Day', xlab = '', 
  panel = function(...) {
    panel.abline(v = d.seq, col = 1, lty = 3)
    panel.grid(h = -1, v = FALSE, col = 1, lty = 3)
    panel.xyplot(...)
  })

filename <- file.path(.figureOutput, 'SDA_daily-ts-decomposition.png')
agg_png(filename = filename, width = 2400, height = 800, res = 100, scaling = 1.5)
print(p)
dev.off()



#### these require > 1 year of data

# 
# ## compare years
# 
# m <- reshape2::melt(d, id.vars = c('year', 'month', 'wkday', 'doy'), measure.vars = c('Trend', 'Raw Data'))
# 
# # take mean over all week days within a year / month
# mm <- reshape2::dcast(m, year + month + wkday ~ variable, fun.aggregate = mean, na.rm = TRUE)
# 
# # convert to percentiles
# e <- ecdf(mm$`Raw Data`)
# mm$pctile <- e(mm$`Raw Data`)
# 
# .cols <- hcl.colors(50, palette = 'zissou1', rev = FALSE)
# 
# p <- levelplot(
#   pctile ~ wkday * year | month, 
#   data = mm, 
#   as.table = TRUE,
#   useRaster = TRUE,
#   xlab = '', ylab = '',
#   main = 'Soil Data Access Daily Queries (Percentiles)', 
#   sub = paste0('updated: ',  u.date), 
#   strip = strip.custom(bg = grey(0.90)), 
#   colorkey = list(space = 'top'),
#   par.settings = tactile.theme(regions = list(col = .cols)),
#   scales = list(
#     x = list(cex = 0.85, alternating = 1),
#     y = list(alternating = 3)
#   )
# )
# 
# 
# filename <- file.path(.figureOutput, 'SDA_day-of-week-grid.png')
# agg_png(filename = filename, width = 1200, height = 900, scaling = 1.5)
# print(p)
# dev.off()
# 
# 
# 
# ## 
# mm <- reshape2::dcast(m, year + doy ~ variable, fun.aggregate = mean, na.rm = TRUE)
# 
# # convert to percentiles
# e <- ecdf(mm$Trend)
# mm$pctile <- e(mm$Trend)
# 
# p <- levelplot(
#   pctile ~ doy * year,
#   data = mm, 
#   as.table = TRUE,
#   useRaster = TRUE,
#   xlab = 'Day of Year', ylab = '',
#   main = 'Web Soil Survey Daily AOI Created (Percentiles, 60-day Trend)', 
#   sub = paste0('updated: ',  u.date), 
#   colorkey = list(space = 'top'),
#   par.settings = tactile.theme(regions = list(col = .cols)),
#   scales = list(
#     x = list(cex = 1, alternating = 1, at = seq(0, 360, by = 30)),
#     y = list(alternating = 3, cex = 1)
#   )
# )
# 
# 
# filename <- file.path(.figureOutput, 'SDA_day-of-year-grid.png')
# agg_png(filename = filename, width = 1200, height = 900, scaling = 2)
# print(p)
# dev.off()
# 
# 
# 
# 
# 
# ## yearly stats by month
# p <- bwplot(yr ~ freq | mo, data = x.daily,
#             as.table = TRUE,
#             par.settings = tactile.theme(),
#             layout = c(3, 4),
#             scales = list(alternating = 3),
#             xlab = 'AOI per Day',
#             main = paste('Updated:',  u.date),
#             panel = function(...) {
#               panel.grid(-1, -1)
#               panel.bwplot(...)
#             }
# )
# 
# 
# filename <- file.path(.figureOutput, 'daily-AOI-by-year-bwplot.png')
# agg_png(filename = filename, width = 1200, height = 900, res = 100)
# print(p)
# dev.off()
# 
# 
# bwplot(mo ~ freq | yr, data = x.daily,
#             as.table = TRUE,
#             par.settings = tactile.theme(),
#             scales = list(alternating = 3),
#             xlab = 'AOI per Day',
#             main = paste('Updated:',  u.date),
#             panel = function(...) {
#               panel.grid(-1, -1)
#               panel.bwplot(...)
#             }
# )
# 


