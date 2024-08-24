
## paths
# .input <- 'E:/backup/Archive_Dylan_Beaudette/NSSC/WSS-access-stats/data'
.gridOutput <- '../../GIS/SDA'
.outlines <- '../../GIS/outlines'
.figureOutput <- '../../results/SDA'

## CRS

# CONUS CRS
crs.conus <- 'EPSG:5070'

# reasonable PCS for AK, HI, PR
# c/o Chad Ferguson
crs.pr <- 'EPSG:32161'
crs.ak <- 'EPSG:3338'
# this one is approximate
crs.hi <- 'EPSG:6628'


## grid spacing, km
# ~ 40 sq. mi. -> 10,180m grid cells --> 10km x 10km is about right
g.conus <- 10
g.pr <- 5
g.hi <- 5
g.ak <- 10

## extents, in native CRS
# manually generated from MLRA outlines and CONUS states
ext.conus <- c(-2356114, 2255906, 279510, 3165722)
ext.pr <- c(39217, 397957, 183044, 275639)
ext.hi <- c(8845, 573845, 8573, 383573)
