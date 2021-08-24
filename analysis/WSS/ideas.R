

tm_shape(r) + 
  tm_raster(palette = viridis(10))

+ 
  
  ###
  library(spData) # contains datasets used in this example
library(sf)     # for handling spatial (vector) data
library(tmap)   # map making package
library(grid)   # to re-arrange maps
library(lattice)
library(sp)

x <- read.csv('WSS-centroids-small.csv.gz', stringsAsFactors = FALSE)

# compute age in days
Sys.setlocale("LC_TIME", "C") 
x$date <- as.Date(x$date)
x$age <- as.numeric(Sys.Date() - x$date)
x <- x[order(x$age), ]

# convert data.frame into suitable sf object
coordinates(x) <- ~ x + y
proj4string(x) <- '+proj=longlat +datum=WGS84'
x <- st_as_sf(x)
x <- st_transform(x, 2163)

us_states2163 <- st_transform(us_states, 2163)


symbol.col <- 'royalblue'
symbol.alpha <- 0.05

age.cols <- rev(RColorBrewer::brewer.pal(10,  'Spectral'))

png(file='WSS-CONUS-2018-2019.png', width=1400, height=1000, res=90, type='cairo', antialias = 'subpixel')

tm_shape(us_states2163) +
  tm_polygons(col = 'white') + 
  tm_shape(x) + tm_symbols(col='age', alpha=0.25, border.lwd=NA, scale=0.125, style='quantile', palette=age.cols, legend.hist=TRUE, legend.hist.title='Query Age (days)') +
  tm_layout(frame = FALSE) + tm_legend(legend.hist.height=0.25)

dev.off()



###

# https://github.com/Nowosad/us-map-alternative-layout/blob/master/R/01_create_alternative_layout.R


# helper function to move geometries --------------------------------------
place_geometry = function(geometry, bb, scale_x, scale_y,
                          scale_size = 1) {
  output_geometry = (geometry - st_centroid(geometry)) * scale_size +
    st_sfc(st_point(c(
      bb$xmin + scale_x * (bb$xmax - bb$xmin),
      bb$ymin + scale_y * (bb$ymax - bb$ymin)
    )))
  return(output_geometry)
}

# us data -----------------------------------------------------------------
data("us_states")
data("alaska")
data("hawaii")

# projections -------------------------------------------------------------
# ESRI:102003 https://epsg.io/102003
crs_lower48 = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
# EPSG:3338 https://epsg.io/3338
crs_alaska = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs "
# ESRI:102007 https://epsg.io/102007
crs_hawaii = "+proj=aea +lat_1=8 +lat_2=18 +lat_0=13 +lon_0=-157 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"


coordinates(x) <- ~ x + y
proj4string(x) <- '+proj=longlat +datum=WGS84'
x <- st_as_sf(x)


z <- x[sample(1:nrow(x), size=1000), ]

## this is quite slow
x <- st_transform(x, st_crs(crs_lower48))

x.hi <- st_transform(z, st_crs(crs_hawaii))
x.ak <- st_transform(z, st_crs(crs_alaska))



# prepare us_lower 48 -----------------------------------------------------
us_lower48 = us_states %>% 
  st_transform(crs_lower48)

# prepare alaska ----------------------------------------------------------
alaska2 = alaska %>% 
  st_transform(crs_alaska) %>% 
  mutate(geometry = place_geometry(geometry, st_bbox(us_lower48), 0.6, 1.35)) %>% 
  st_set_crs(crs_lower48)

# prepare hawaii ----------------------------------------------------------
hawaii2 = hawaii %>% 
  st_transform(crs_hawaii) %>% 
  mutate(geometry = place_geometry(geometry, st_bbox(us_lower48), 0.2, 0.1)) %>% 
  st_set_crs(crs_lower48)

# combine data ------------------------------------------------------------
us_albers_alt = rbind(us_lower48, alaska2, hawaii2)


tm_shape(us_albers_alt) +
  tm_shape(z) +  tm_dots(col='blue', alpha=0.25, border.lwd=NA, scale=0.125) +
  tm_polygons(col = grey(0.9), 
              border.col = "black", lwd = 0.5)



