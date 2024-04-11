library(latticeExtra)
library(reshape2)
library(tactile)
library(ragg)

## common configuration
source('config.R')

# source data, pre-processed
x.daily <- readRDS(file.path(.input, 'app-2x-daily.Rds'))

# note that there is a gap
x <- subset(x.daily, subset=date > as.Date('2019-04-01'))

# init TS object
x.ts <- ts(x$freq, frequency = 30, start=c(2019, 4, 1))

# STL decomposition
x.stl <- stl(x.ts, s.window = 'periodic')

# convert to DF and re-name
d <- as.data.frame(x.stl$time.series)
d$date <- x$date
d$raw <- x$freq
names(d) <- c('Seasonal', 'Trend', 'Remainder', 'date', 'Raw Data')

# extra columns for grouping
d$year <- as.integer(format(d$date, "%Y"))
d$doy <- as.integer(format(d$date, "%j"))
d$wkday <- factor((format(d$date, "%a")), levels = c('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'), ordered = TRUE)
d$month <- factor(format(d$date, "%b"), levels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))





# new version, just the trend + raw data
m <- melt(d, id.vars = 'date', measure.vars = c('Trend', 'Raw Data'))

# updated 
md <- max(x$date, na.rm=TRUE)
u.date <- as.character(md)

# labels for x-axis
d.seq <- seq.Date(from=as.Date('2019-04-01'), to = md, by = '3 months')


p <- xyplot(value ~ date | variable, data=m, 
			subset=value < quantile(x.daily$freq, 0.999, na.rm=TRUE),
			xlim=c(min(d.seq)-10, md+10),
            main=paste('SoilWeb App 2.x\nupdated',  u.date), sub='Timeseries Decomposition by STL (1 month period)', 
            type='l', 
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

filename <- file.path(.figureOutput, 'app-2x_daily-ts-decomposition.png')
agg_png(filename = filename, width=1400, height=650, res=100)
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
  main = 'SoilWeb App 2.x Daily Queries (Percentile)', 
  sub = paste0('updated: ',  u.date), 
  strip = strip.custom(bg = grey(0.90)), 
  colorkey = list(space = 'top'),
  par.settings = tactile.theme(regions = list(col = .cols)),
  scales = list(
    x = list(cex = 0.85, alternating = 1),
    y = list(alternating = 3)
  )
)


filename <- file.path(.figureOutput, 'app-2x_day-of-week-grid.png')
agg_png(filename = filename, width = 1200, height = 800, scaling = 1.5)
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
  main = 'SoilWeb App 2.x Daily Queries (Percentiles, 60-day Trend)', 
  sub = paste0('updated: ',  u.date), 
  colorkey = list(space = 'top'),
  par.settings = tactile.theme(regions = list(col = .cols)),
  scales = list(
    x = list(cex = 1, alternating = 1, at = seq(0, 360, by = 30)),
    y = list(alternating = 3, cex = 1)
  )
)


filename <- file.path(.figureOutput, 'app-2x_day-of-year-grid.png')
agg_png(filename = filename, width = 1200, height = 800, scaling = 2)
print(p)
dev.off()






## cleanup
rm(list = ls())
gc(reset = TRUE)



