library(latticeExtra)
library(reshape2)
library(tactile)
library(ragg)

## configuration
# global
source('../../analysis/global-config.R')
# local
source('config.R')

# source data, pre-processed
x.daily <- readRDS(file.path(.input, 'gmap-daily.Rds'))

# keep data from September 01 2014
x <- subset(x.daily, subset = date > as.Date('2014-09-01'))

# for yearly stats
x$yr <- format(x$date, '%Y')

# init TS object
x.ts <- ts(x$freq, frequency = 60, start = c(2014, 9, 1))

# STL decomposition
x.stl <- stl(x.ts, s.window = 'periodic')

# convert to DF
d <- as.data.frame(x.stl$time.series)
d$date <- x$date
d$raw <- x$freq
names(d) <- c('Seasonal', 'Trend', 'Remainder', 'date', 'Raw Data')


d$year <- as.integer(format(d$date, "%Y"))
d$doy <- as.integer(format(d$date, "%j"))
d$wkday <- factor((format(d$date, "%a")), levels = c('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'), ordered = TRUE)
d$month <- factor(format(d$date, "%b"), levels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))




# old version: TMI
# m <- melt(d, id.vars = 'date')

# new version, just the trend + raw data
m <- melt(d, id.vars = 'date', measure.vars = c('Trend', 'Raw Data'))

# last updated 
md <- max(x$date, na.rm=TRUE)
u.date <- as.character(md)

# labels for x-axis
d.seq <- seq.Date(from=as.Date('2014-09-01'), to=md, by='4 months')

## notes:
## * truncating to the 99.9th percentile of daily hits due to a funky spike

p <- xyplot(value ~ date | variable, data=m, 
			subset=value < quantile(x.daily$freq, 0.999, na.rm=TRUE),
            main=paste('SoilWeb Gmaps\nupdated',  u.date), sub='Timeseries Decomposition by STL (60-day period)', 
            type='l', 
			xlim=c(min(d.seq)-10, md+10),
            layout=c(1,2), 
            scales=list(alternating=3, x=list(at=d.seq, format='%b\n%Y'), y=list(relation='free', rot=0, tick.number=8)), 
            col=rgb(73, 107, 154, max=255), lwd=1.5, 
            strip=strip.custom(bg=grey(0.90)), 
            ylab='Queries per Day', xlab='', 
            panel=function(...) {
              panel.abline(v=d.seq, col=1, lty=3)
              panel.grid(h=-1, v=FALSE, col=1, lty=3)
              panel.xyplot(...)
})

filename <- file.path(.figureOutput, 'gmap_daily-ts-decomposition.png')
ragg::agg_png(filename = filename, width = 1400, height = 650, res = 100)
print(p)
dev.off()


## yearly stats
p <- bwplot(yr ~ freq, data = x,
par.settings = tactile.theme(),
scales = list(x = list(log = 10)),
xscale.components = xscale.components.log10ticks,
xlab = 'Requests per Day',
main = paste('SoilWeb Gmaps updated:',  u.date)
)


filename <- file.path(.figureOutput, 'gmap_yearly-bwplot.png')
agg_png(filename = filename, width = 1000, height = 450, res = 100)
print(p)
dev.off()



## compare years

m <- reshape2::melt(d, id.vars = c('year', 'month', 'wkday', 'doy'), measure.vars = c('Trend', 'Raw Data'))

# take mean over all week days within a year / month
mm <- reshape2::dcast(m, year + month + wkday ~ variable, fun.aggregate = mean, na.rm = TRUE)

# convert raw data to percentiles
e <- ecdf(mm$`Raw Data`)
mm$pctile <- e(mm$`Raw Data`)

.cols <- hcl.colors(50, palette = 'zissou1', rev = FALSE)

p <- levelplot(
  pctile ~ wkday * year | month, 
  data = mm, 
  as.table = TRUE,
  useRaster = TRUE,
  xlab = '', ylab = '',
  main = 'SoilWeb Gmap Daily Queries (Percentile)', 
  sub = paste0('updated: ',  u.date), 
  strip = strip.custom(bg = grey(0.90)), 
  colorkey = list(space = 'top'),
  par.settings = tactile.theme(regions = list(col = .cols)),
  scales = list(
    x = list(cex = 0.85, alternating = 1),
    y = list(alternating = 3)
  )
)


filename <- file.path(.figureOutput, 'gmap_day-of-week-grid.png')
agg_png(filename = filename, width = 1200, height = 900, scaling = 1.5)
print(p)
dev.off()




## 
mm <- reshape2::dcast(m, year + doy ~ variable, fun.aggregate = mean, na.rm = TRUE)

# convert trend to percentiles
e <- ecdf(mm$Trend)
mm$pctile <- e(mm$Trend)


p <- levelplot(
  pctile ~ doy * year,
  data = mm, 
  as.table = TRUE,
  useRaster = TRUE,
  xlab = 'Day of Year', ylab = '',
  main = 'SoilWeb Gmap Daily Queries (Percentiles, 60-day Trend)', 
  sub = paste0('updated: ',  u.date), 
  colorkey = list(space = 'top'),
  par.settings = tactile.theme(regions = list(col = .cols)),
  scales = list(
    x = list(cex = 1, alternating = 1, at = seq(0, 360, by = 30)),
    y = list(alternating = 3, cex = 1)
  )
)


filename <- file.path(.figureOutput, 'gmap_day-of-year-grid.png')
agg_png(filename = filename, width = 1200, height = 900, scaling = 2)
print(p)
dev.off()







## cleanup
rm(list = ls())
gc(reset = TRUE)


