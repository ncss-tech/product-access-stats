## source data are stored locally



## TODO: append vs. 100% rebuild each iteration

# fast file reading, sorting, and unique() methods
library(data.table)
# library(terra)
# library(sf)
# library(purrr)

# bogus geometry may result in NULL values for x,y
x <- fread('../../CART_Soils_Centroid_x_y_20240820_v2.csv', na.strings = 'NULL')

# there are likely duplicates due to overlap in input files
x <- unique(x)

# proceed as data.frame
x <- as.data.frame(x)

# 2024: 1,256,702 rows
nrow(x)

# # check for invalid WKT ... but why?
# # this is very inefficient, surely there is a better way!
# wkt.errors <- map_lgl(1:nrow(x), .progress = TRUE, .f = function(i) {
#   .res <- try(st_as_sf(x[i, ], wkt = 'land_unit_geometry'), silent = TRUE)
#   if(inherits(.res, 'try-error')) {
#     return(TRUE)
#   } else {
#     return(FALSE)
#   }
# })
# 
# any(wkt.errors)

# 
# # temp fix, next version iteration will not have these
# wkt.errors <- c(880632, 1037802)
# 
# x <- x[-wkt.errors, ]
# 
# 
# # convert WKT -> x, y
# v <- vect(x, geom = 'land_unit_geometry')
# x <- crds(v, df = TRUE)

# TODO: move over land unit IDs

## rename columns and subset
x$x <- as.numeric(x$long_x)
x$y <- as.numeric(x$lat_y)


# log ID
x$LogID <- 1:nrow(x)

# fix date
x$date <- as.Date(x$log_date)

# add year/month
x$ym <- format(x$date, "%Y-%m")

# remove rows containing NA
x <- na.omit(x)


x <- x[, c('LogID', 'date', 'x', 'y')]

# save for later
saveRDS(x, file = file.path('AOI-points.rds'))


## cleanup
rm(list = ls())
gc(reset = TRUE)




