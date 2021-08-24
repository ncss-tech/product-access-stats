library(readr)

## work in local data directory
setwd(file.path(wd, 'data'))


#### first version from Jason, has column names

x <- read_delim('WSS_Centroid42018_42019.csv', delim = ',', na = '', col_names = TRUE, guess_max = 1e6)
x <- as.data.frame(x)

x$date <- as.Date(x$log_date, format='%m-%d-%y')
x$x <- x$long_x
x$y <- x$lat_y

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-18-19.csv.gz'), row.names = FALSE)


#### slightly different format, missing names

x <- read_delim('WSS_Centroid_42017_42018.csv', delim = ',', na = '', col_names = FALSE, guess_max = 1e6)
x <- as.data.frame(x)

x$date <- as.Date(x$X7, format='%m-%d-%y')
x$x <- x$X13
x$y <- x$X12
x$LogID <- x$X1

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-17-18.csv.gz'), row.names = FALSE)



#### another one, slightly different format

x <- read_delim('WSS_Centroid_42016_42017.csv', delim = ',', na = '', col_names = FALSE, guess_max = 1e6)
x <- as.data.frame(x)

x$date <- as.Date(x$X7, format='%m-%d-%y')
x$x <- x$X12
x$y <- x$X11
x$LogID <- x$X1

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-16-17.csv.gz'), row.names = FALSE)


#### another one

x <- read_delim('WSS_Centroid_42015_42016.csv', delim = ',', na = '', col_names = FALSE, guess_max = 1e6)
x <- as.data.frame(x)

head(x)

x$date <- as.Date(x$X7, format='%m-%d-%y')
x$x <- x$X12
x$y <- x$X11
x$LogID <- x$X1

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-15-16.csv.gz'), row.names = FALSE)


#### 2019-10-03 new file, slightly different format

x <- read_delim('Centroid_04012019_to_10012019.csv', delim = ',', na = '', col_names = FALSE, guess_max = 1e6)
x <- as.data.frame(x)

head(x)

x$date <- as.Date(x$X3, format='%m-%d-%y')
x$x <- x$X8
x$y <- x$X7
x$LogID <- x$X1

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-10-2019.csv.gz'), row.names = FALSE)


#### 2020-05-20 new file, slightly different format

x <- read_delim('Centroid_10012019_5102020.csv', delim = ',', na = '', col_names = TRUE, guess_max = 1e6)
x <- as.data.frame(x)

head(x)

x$date <- as.Date(x$log_date, format='%m-%d-%y')
x$x <- x$long_x
x$y <- x$lat_y

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-05-2020.csv.gz'), row.names = FALSE)


#### 2020-10-06 new file, slightly different format

x <- read_delim('Centroid_05112020_09302020.csv', delim = ',', na = '', col_names = TRUE, guess_max = 1e6)
x <- as.data.frame(x)

head(x)

x$date <- as.Date(x$log_date, format='%m-%d-%y')
x$x <- x$long_x
x$y <- x$lat_y

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-10-2020.csv.gz'), row.names = FALSE)


#### 2021-06-30 new file

x <- read_delim('WSS_Centroid_10-01-2020--6-30-2021.csv', delim = ',', na = '', col_names = TRUE, guess_max = 1e6)
x <- as.data.frame(x)

head(x)

x$date <- as.Date(x$log_date, format='%m-%d-%y')
x$x <- x$long_x
x$y <- x$lat_y

x <- x[, c('LogID', 'x', 'y', 'date')]
# ok
head(x)

# ~ 1 minute
write.csv(x, file=gzfile('WSS-centroids-06-2021.csv.gz'), row.names = FALSE)





