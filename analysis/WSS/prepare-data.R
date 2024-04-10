## source data are stored locally



## TODO: append vs. 100% rebuild each iteration

# fast file reading, sorting, and unique() methods
library(data.table)

# subsets of original data
fp <- file.path(wd, 'data')
f <- list.files(path = fp, pattern='\\.csv.gz', full.names = TRUE)

# read / combine
x <- lapply(f, fread)
x <- do.call('rbind', x)

# fix date
x$date <- as.Date(x$date)

# add year/month
x$ym <- format(x$date, "%Y-%m")

# there are likely duplicates due to overlap in input files
x <- unique(x)

# proceed as data.frame
x <- as.data.frame(x)

# re-order by date
x <- x[order(x$date), ]

# 2023: 25,069,424 rows
# 2024: 28,800,000 rows
nrow(x)

# save for later
saveRDS(x, file = file.path(fp, 'AOI-points.rds'))

# cleanup



