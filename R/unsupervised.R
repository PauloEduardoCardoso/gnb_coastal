## First steps in remote sensing with R
library(raster)
library(RStoolbox)
library(cluster)
library(rgdal)
graphics.off()
rm(list=ls())

#beginCluster() #Required when using RStoolbox functions. It is also supposed to speed up processing of raster and rs-related functions

#'## import shape guine-bissau
gnb <- readOGR("D:/Dropbox/programacao/gnb_coastal/gis", "gnb_utm28n")
plot(gnb)

#'## import landsat 8 ESPA bands into R
ESPA_lds8_2017 <- readMeta("G:/satelite/landsat/LC082040522017010601T1/LC08_L1TP_204052_20170106_20170312_01_T1_MTL.txt")
summary(ESPA_lds8_2017)
str(ESPA_lds8_2017)

stk <- stack(
  list.files('G:/satelite/landsat/LC082040522017010601T1', recursive = TRUE
             , pattern = glob2rx("*sr_band*tif$")
             , full.names = T)
)

#'## Claud Mask using ESPA pixel_qa layer: NOT USED YET
#'## https://landsat.usgs.gov/landsat-surface-reflectance-quality-assessment
cshadow <- c(328, 392, 840, 904, 1350)
clouds <- c(352, 368, 416, 432, 480, 864, 880, 928, 944, 992)
pixel_qa <- raster(list.files('G:/satelite/landsat/LC082040522017010601T1'
                              , recursive = T
                              , pattern = glob2rx("*pixel_qa*tif$")
                              , full.names = T)
)
#ggR(pixel_qa)
plot(pixel_qa)


#'## Plotting
plotRGB(stk, r=4,g=3,b=2, stretch="lin", ext=gnb[which(gnb$name_1 == "Bolama"),], axes=T)
plot(gnb, add=T)
#ggRGB(ESPA_lds8_2017_stack,r=3,g=2,b=1, stretch ="hist", ext=gnb)

#'## cortar a multilayer ESPA com a shape da guine
cropstk <- crop(stk, gnb[which(gnb$name_1 == "Bolama"), ])
plotRGB(cropstk,r=4,g=3,b=2, stretch="lin", axes=T, main="crop1")

#'## Water mask based on sr_band6 only
water0 <- cropstk[[6]]
m <- c(-Inf, 250, 0 # water
       ,250, Inf, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
water <- reclassify(water0, rclmat, include.lowest=FALSE, right=TRUE
                    #, filename = file.path(dir.work, 'gnb_intertidal1986_.tif')
                    #, options = c("TFW=YES")
                    #, overwrite = TRUE, datatype = 'INT1U'
)
plot(water, main="water mask")

#'## Land mask
land0 <- cropstk[[6]]
land0[] <- 0
land <- mask(land0, gnb#[which(gnb$name_1 == "Bolama"), ]
             , updatevalue = 1, updateNA = T)
plot(land, main="land mask")

landwat <- land*water
plot(landwat, main = 'sediment mask')

#'##### unsupervised class attempt ############################################
#'## abordagem raster package (3 different cassification)
stk_sed <- cropstk * landwat
plot(stk_sed[[1]], main="stk 1")

values1_ESPA <- getValues(stk_sed)
i <- which(!is.na(values1_ESPA))
values1_ESPA <- na.omit(values1_ESPA)
head(values1_ESPA)
tail(values1_ESPA)

#'# kmeans classification 
l8kmeans <- kmeans(values1_ESPA, 6, iter.max = 10, nstart = 10)
kmeans_raster <- raster(stk_sed)
kmeans_raster[i] <- l8kmeans$cluster
plot(kmeans_raster, col=rainbow(20))

writeRaster(kmeans_raster
            , filename = file.path('G:/satelite/coastalGNB/sedimentos/gnb_intertidal2017_kmeans6_.tif')
            , options = c("TFW=YES")
            , overwrite = TRUE, datatype = 'INT1U'
)

#'# clara classification 
clus <- clara(values1_ESPA, 15, samples=20, metric="manhattan", pamLike=T)
clara_raster <- raster(stk_sed)
clara_raster[i] <- clus$clustering
plot(clara_raster)

# done with cluster object		
endCluster()
