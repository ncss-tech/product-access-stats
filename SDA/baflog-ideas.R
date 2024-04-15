
## TODO:
## * integrate with WSS and SoilWeb
## * split into point, bbox, polygon queries


library(readr)
library(terra)
library(stringi)
library(spData)

# 10104148 rows
x <- read_csv('E:/temp/SDA_baflogs_Metrics_Spatial_22_23_v3.csv')
nrow(x)
x <- as.data.frame(x)

head(x)

table(x$geometry_type)
table(x$spatialoutputsrid)

tab <- table(x$geometry_type, x$spatialoutputsrid)
round(prop.table(tab, margin = 1) * 100)

# 4851107 rows
bb <- x[x$geometry_type == 'bbox', ]
nrow(bb)
.xy <- stri_split_fixed(bb$coordinates, pattern = ',', simplify = TRUE)

# format for ext()
apply(.xy, MARGIN = 1, FUN = function(i) {
  
})


## point data
## all EPSG:4269

## notes:
# * "-98.5,40.0" is very common, maybe default?
# * illegal coordinates present


p <- x[x$geometry_type == 'point', ]

.xy <- stri_split_fixed(p$coordinates, pattern = ',', simplify = TRUE)
.xy <- data.frame(p[, c('logid', 'log_date')], x = as.numeric(.xy[, 1]), y = as.numeric(.xy[, 2]))

# cleanup coordinates
.xy <- na.omit(.xy)
.xy <- .xy[.xy$x >= -180 & .xy$x <= 180, ]
.xy <- .xy[.xy$y >= -90 & .xy$y <= 90, ]

# 147607
nrow(.xy)

z <- vect(.xy, geom = c('x', 'y'), crs = 'EPSG:4269')

data(us_states)

us_states <- vect(us_states)

us_states <- project(us_states, 'epsg:5070')
z <- project(z, 'epsg:5070')

plot(us_states, axes = FALSE, mar = c(0, 0, 0, 0))
points(z, cex = 0.25, col = 'royalblue')
