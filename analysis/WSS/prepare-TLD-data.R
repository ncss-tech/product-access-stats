library(readr)

#### 2019-10-07 new file with TLDs

# LogID|year|month|day|time|LogDateTime|log_date|ipaddress|Domain|aoi_centroid_name|lat_y|long_x
# 684475734|2017|10|1|12:02|2017-10-01 00:02:00.887|10-01-17|71.223.197.44|net|AOICentroid|35.17439|-111.65301
# 684475743|2017|10|1|12:02|2017-10-01 00:02:10.543|10-01-17|69.178.27.156|net|AOICentroid|61.56401|-149.73077

# file list
# next time generate dynamically
fl <- c('data/centroid_domain_2017_10_01_to_2018_09_30.txt', 'data/centroid_domain_2018_10_01_to_2019_09_30.txt')

gd <- function(f) {
  # hopefull this format doesn't change
  x <- read_delim(f, delim = '|', na = '', col_names = TRUE, guess_max = 1e6)
  x <- as.data.frame(x)
  
  # subset / re-name columns
  x <- x[, c('LogID', 'long_x', 'lat_y', 'log_date', 'Domain', 'ipaddress')]
  names(x) <- c('LogID', 'x', 'y', 'date', 'TLD', 'ip')
  
  # fix date
  x$date <- as.Date(x$date, format = '%M-%d-%y')
  
  return(x)
}


x.tld <- lapply(fl, gd)
x.tld <- do.call('rbind', x.tld)

# re-order
x.tld <- x.tld[order(x.tld$date), ]

# just in case remove dupes
x.tld <- unique(x.tld)

# save for later
save(x.tld, file='data/AOI-points-TLD.rda')


