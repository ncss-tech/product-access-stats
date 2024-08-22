
## paths
.input <- './'
.gridOutput <- '../../GIS/CART'
.outlines <- '../../GIS/outlines'
.figureOutput <- '../../results/CART'

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
g.pr <- 2
g.hi <- 5
g.ak <- 10

