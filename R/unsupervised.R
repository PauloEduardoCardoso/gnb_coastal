#'# Packages
kpacks <- c('raster', 'sp', 'rgdal', 'RStoolbox', 'cluster')
new.packs <- kpacks[!(kpacks %in% installed.packages()[ ,"Package"])]
if(length(new.packs)) install.packages(new.packs)
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)

graphics.off()
rm(list=ls())

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

#ggRGB(ESPA_lds8_2017_stack,r=3,g=2,b=1, stretch ="hist", ext=gnb)

#'## Claud Mask using ESPA pixel_qa layer: NOT USED YET
#'## https://landsat.usgs.gov/landsat-surface-reflectance-quality-assessment
#cshadow <- c(328, 392, 840, 904, 1350)
#clouds <- c(352, 368, 416, 432, 480, 864, 880, 928, 944, 992)
#pixel_qa <- raster(list.files('G:/satelite/landsat/LC082040522017010601T1'
#                              , recursive = T
#                              , pattern = glob2rx("*pixel_qa*tif$")
#                              , full.names = T)
#)
#ggR(pixel_qa)
#plot(pixel_qa)

#'## cortar a multilayer ESPA com a shape da guine
cropstk <- crop(stk, gnb[which(gnb$name_1 == "Bolama"), ])
plotRGB(cropstk,r=4,g=3,b=2, stretch="lin", axes=T, main="crop1")
plot(gnb, add=T)

#'## Water mask based on sr_band6 only threshold = 250 ########################
water0 <- cropstk[[6]]
m <- c(-Inf, 250, 0 # water
       ,250, Inf, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)

beginCluster()
water <- raster::clusterR(water0, # Parallel
                          reclassify, args=list(rcl=rclmat, include.lowest=FALSE, right=TRUE)
)
raster::endCluster()

plot(water, main="water mask")

#'## Land mask ################################################################
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
stk_sed@data@names <- gsub('layer.', 'b', stk_sed@data@names )
plot(stk_sed[[1]], main="stk 1")

values1_ESPA <- getValues(stk_sed)
i <- which(!is.na(values1_ESPA))
values1_ESPA <- na.omit(values1_ESPA)
head(values1_ESPA)
tail(values1_ESPA)

#'# kmeans classification  ###
l8kmeans <- kmeans(values1_ESPA, 8, iter.max = 20, nstart = 10)
kmeans_raster <- raster(stk_sed)
kmeans_raster[i] <- l8kmeans$cluster
plot(kmeans_raster, col=rainbow(20))

writeRaster(kmeans_raster
            , filename = file.path('G:/satelite/coastalGNB/sedimentos/gnb_intertidal2017_kmeans8_.tif')
            , options = c("TFW=YES")
            , overwrite = TRUE, datatype = 'INT1U'
)

#'# clara classification 
clus <- clara(values1_ESPA, 8, samples=20, metric="manhattan", pamLike=T)
clara_raster <- raster(stk_sed)
clara_raster[i] <- clus$clustering
plot(clara_raster)

writeRaster(clara_raster
            , filename = file.path('G:/satelite/coastalGNB/sedimentos/gnb_intertidal2017_clara8_.tif')
            , options = c("TFW=YES")
            , overwrite = TRUE, datatype = 'INT1U'
)

library(tidyverse)
#' Landsata 8 wavelenghts
#' 
l8wl <- read.table('G:/satelite/landsat/landsat8wavelenght.txt', sep = '\t',
                   stringsAsFactors = F, header = T)
l8wl

vec <- data.frame(cbind(as.vector(clara_raster), values1_ESPA)) %>%
  gather(key=band, value=sr, -V1) %>% 
  filter(V1 != 1) %>%
  group_by(V1, band) %>%
  summarise(msr = mean(sr/10000), stdv = sd(sr/10000)) %>%
  mutate(band=gsub('layer.', 'b', band)) %>%
  left_join(l8wl, by = 'band')
vec %>%
  ggplot(aes(x=med, y=msr)) +
  geom_ribbon(aes(fill = factor(V1), ymax = msr + stdv, ymin = msr - stdv), alpha = 0.2) +
  geom_path(aes(group = factor(V1), colour = factor(V1))) +
  geom_point(aes(colour = factor(V1))) +
  labs(caption='Clara cluster Spectral signature'
       ,x=expression('wavelenght'*(mu*m))
       ,y='value', fill = 'Cluster', colour = 'Cluster'
  ) 
