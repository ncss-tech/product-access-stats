library(readr)
library(reshape2)

## paths
.input <- 'E:/work-file-system/SoilWeb/access-tracking/data'
.output <- 'processed-data'

## cleanup from last time
unlink(.output, force = TRUE, recursive = TRUE)
dir.create(.output, recursive = TRUE)

## GMAPS data

## read in data extracted from Apache logs, one from each server
.file <- file.path(.input, 'gmap_queries.longlat-1.gz')
x.1 <- read_delim(
  .file, 
  col_names = c('x', 'y', 'dt'), delim = ' ', col_types = list(col_double(), col_double(), col_character())
)

.file <- file.path(.input, 'gmap_queries.longlat-2.gz')
x.2 <- read_delim(
  .file, 
  col_names = c('x', 'y', 'dt'), delim = ' ', col_types = list(col_double(), col_double(), col_character())
)

## combine
x <- rbind(as.data.frame(x.1), as.data.frame(x.2))

## convert date-time to date
Sys.setlocale("LC_TIME", "C") 
x$date <- as.Date(strptime(substring(as.character(x$dt), 1, 11), format = '%d/%b/%Y'))
x$dt <- NULL

## keep only valid coordinates
idx <- which(x$y > -90 & x$y < 90 & x$x > -180 & x$x < 180)
x <- x[idx, ]
x <- na.omit(x)

## daily summaries
x.daily <- tapply(x$date, x$date, length)
x.daily <- data.frame(date = as.Date(names(x.daily)), freq = x.daily)

## save to Rds for later
saveRDS(x, file = file.path(.output, 'gmap.Rds'))
saveRDS(x.daily, file = file.path(.output, 'gmap-daily.Rds'))



## KSSL API requests
# read in data extracted from Apache logs, one from each server
.file <- file.path(.input, 'kssl_queries-1.gz')
x.1 <- read_delim(
  .file, 
  col_names = c('date', 'IP'), delim = ' ', col_types = list(col_character(), col_character())
)

.file <- file.path(.input, 'kssl_queries-2.gz')
x.2 <- read_delim(
  .file, 
  col_names = c('date', 'IP'), delim = ' ', col_types = list(col_character(), col_character())
)

## combine
x <- rbind(as.data.frame(x.1), as.data.frame(x.2))

## TODO: consider keeping HMS
# convert date-time to date
Sys.setlocale("LC_TIME", "C") 
x$date <- as.Date(strptime(substring(as.character(x$date), 1,11), format = '%d/%b/%Y'))

## cleaning
x <- na.omit(x)

## local vs. external
x$source <- 'external'
x$source[x$IP == '127.0.0.1'] <- 'local'

## tabulate daily totals
x.daily <- dcast(x, date ~ source, fun.aggregate = length, value.var = 'source')

## save to Rds for later
saveRDS(x, file = file.path(.output, 'KSSL.Rds'))
saveRDS(x.daily, file = file.path(.output, 'KSSL-daily.Rds'))



## SoilWeb App 2.x
# read in data extracted from Apache logs, one from each server
.file <- file.path(.input, 'app2_queries.longlat-1.gz')
x.1 <- read_delim(
  .file,
  col_names = c('x', 'y', 'dt'), delim = ' ', col_types = list(col_double(), col_double(), col_character())
)

.file <- file.path(.input, 'app2_queries.longlat-2.gz')
x.2 <- read_delim(
  .file,
  col_names = c('x', 'y', 'dt'), delim = ' ', col_types = list(col_double(), col_double(), col_character())
)

## combine
x <- rbind(as.data.frame(x.1), as.data.frame(x.2))

## convert date-time to date
Sys.setlocale("LC_TIME", "C")
x$date <- as.Date(strptime(substring(as.character(x$dt), 1,11), format = '%d/%b/%Y'))
x$dt <- NULL

## keep only valid coordinates
idx <- which(x$y > -90 & x$y < 90 & x$x > -180 & x$x < 180)
x <- x[idx, ]
x <- na.omit(x)

## daily summaries
x.daily <- tapply(x$date, x$date, length)
x.daily <- data.frame(date = as.Date(names(x.daily)), freq = x.daily)

# save to Rds for later
saveRDS(x, file = file.path(.output, 'app-2x.Rds'))
saveRDS(x.daily, file = file.path(.output, 'app-2x-daily.Rds'))


### SoilWeb App 1.x

# read in data extracted from Apache logs, one from each server
.file <- file.path(.input, 'iphone_queries.longlat-1.gz')
x.1 <- read_delim(
  .file,
  col_names = c('x', 'y', 'dt', 'phone_type'), delim = ' ', col_types = list(col_double(), col_double(), col_character(), col_character())
)

.file <- file.path(.input, 'iphone_queries.longlat-2.gz')
x.2 <- read_delim(
  .file,
  col_names = c('x', 'y', 'dt', 'phone_type'), delim = ' ', col_types = list(col_double(), col_double(), col_character(), col_character())
)

# read-in historic data
.file <- file.path(.input, 'historic-data', 'iphone-historic.lonlat')
x.3 <- read_delim(
  .file,
  col_names=c('x', 'y', 'dt', 'phone_type'), delim = ' ', col_types = list(col_double(), col_double(), col_character(), col_character())
)

## combine
x <- rbind(
  as.data.frame(x.1), 
  as.data.frame(x.2), 
  as.data.frame(x.3)
)

## convert date-time to date
Sys.setlocale("LC_TIME", "C") 
x$date <- as.Date(strptime(substring(as.character(x$dt), 1,11), format = '%d/%b/%Y'))
x$dt <- NULL

## keep only valid coordinates
idx <- which(x$phone_type != '' & x$y > -90 & x$y < 90 & x$x > -180 & x$x < 180)
x <- x[idx, ]
x <- na.omit(x)

## hits / day
x.daily <- tapply(x$date, x$date, length)
x.daily <- data.frame(date = as.Date(names(x.daily)), freq = x.daily)

# save to Rds for later
saveRDS(x, file = file.path(.output, 'app-1x.Rds'))
saveRDS(x.daily, file = file.path(.output, 'app-1x-daily.Rds'))



### GE Data

# too large to perform here


## cleanup
rm(list = ls())
gc(reset = TRUE)



