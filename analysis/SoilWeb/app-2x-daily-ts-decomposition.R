library(lattice)
library(reshape2)
library(tactile)

# source data, pre-processed
load('processed-data/app-2x.Rda')

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

# old version: TMI
# m <- melt(d, id.vars = 'date')

# new version, just the trend + raw data
m <- melt(d, id.vars = 'date', measure.vars = c('Trend', 'Raw Data'))

# updated 
md <- max(x$date, na.rm=TRUE)
u.date <- as.character(md)

# labels for x-axis
d.seq <- seq.Date(from=as.Date('2019-04-01'), to=md, by='1 months')


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

filename <- 'figures/app-2x_daily-ts-decomposition.png'
png(file=filename, width=1400, height=650, res=100, type='cairo', antialias='subpixel')
print(p)
dev.off()


