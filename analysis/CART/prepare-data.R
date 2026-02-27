## source data are stored locally



## TODO: append vs. 100% rebuild each iteration


## Data Sources (2026-02-27)

# CART_4_years_sda.csv.gz:                        4,602,217 rows  ["2020-08-22" "2024-08-22"]
# CART Soil Assessments.csv.gz:                   4,930,503 rows  ["2021-09-05" "2025-09-05"]
# CART_Soils_Centroid_x_y_20240820_20260218.csv:  1,420,552 rows  ["2024-08-22" "2026-01-31"]


library(data.table)

# local config
source('config.R')

# work through input files, there may be overlap in dates
# bogus geometry may result in NULL values for x,y

x1 <- fread(file.path(.sourcePath, 'CART Soil Assessments.csv.gz'), na.strings = 'NULL')

x2 <- fread(file.path(.sourcePath, 'CART_Soils_Centroid_x_y_20240820_20260218.csv.gz'), na.strings = 'NULL')

# combine
x <- rbind(x1, x2)

# there are likely duplicates due to overlap in input files
x <- unique(x)

# proceed as data.frame
x <- as.data.frame(x)


# 2026-02-27: 5026376 rows ["2021-09-05" "2026-01-31"]
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

# fix date
x$date <- as.Date(x$log_date)

# add year/month
x$ym <- format(x$date, "%Y-%m")

# remove rows containing NA
x <- na.omit(x)

# sort by date
x <- x[order(x$date), ]

# log ID
x$LogID <- 1:nrow(x)

# subset columns
x <- x[, c('LogID', 'date', 'ym', 'x', 'y')]


# save for later
saveRDS(x, file = file.path(.sourcePath, 'AOI-points.rds'))


## cleanup
rm(list = ls())
gc(reset = TRUE)




