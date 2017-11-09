## First steps in remote sensing with R
require(maptools)
require(raster)
require(RStoolbox)
require(ggplot2)
require(RColorBrewer)
require(colorRamps)
require(cluster)
require(randomForest)
graphics.off()
rm(list=ls())

beginCluster() #Required when using RStoolbox functions. It is also supposed to speed up processing of raster and rs-related functions

## extract Landsat 8 imagery - all bands. tar format file, only execute once
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/LC08_L1TP_204052_20170106_20170312_01_T1.tar.gz", list=T)
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/LC08_L1TP_204052_20170106_20170312_01_T1.tar.gz", list=F, exdir = "D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/Ladsat_8_img_06012017")

## extract landsat 8  - ESPA preprocessed product: stats
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/espa-mhenriquesbalde@gmail.com-11092017-001802-124-statistics.tar.gz", list=T)
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/espa-mhenriquesbalde@gmail.com-11092017-001802-124-statistics.tar.gz", list=F, exdir = "D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017")

## extract landsat 8 - ESPA preprocessed imagery
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/LC082040522017010601T1-SC20171109002445.tar.gz", list=T)
#untar("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/LC082040522017010601T1-SC20171109002445.tar.gz", list=F, exdir = "D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017")

## import shape guine-bissau
gnb<-readShapePoly("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/gis/gis/gnb_utm28n.shp")
plot(gnb)

### import all landsat bands into R environment
#lds8_2017<-readMeta("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/Ladsat_8_img_06012017/LC08_L1TP_204052_20170106_20170312_01_T1_MTL.txt")
#summary(lds8_2017)
#str(lds8_2017)

### import landsat 8 ESPA bands into R 
ESPA_lds8_2017<-readMeta("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/LC08_L1TP_204052_20170106_20170312_01_T1_MTL.txt")
summary(ESPA_lds8_2017)
str(ESPA_lds8_2017)

### Load and label metadata from all bands, ensuring the correct link between each band and its corresponding meta data parameters
#lds8_2017_stack<-stackMeta(lds8_2017)
#lds8_2017_stack

### Load and label metadata from all bands - ESPA
ESPA_lds8_2017_stack<-stackMeta(ESPA_lds8_2017)
ESPA_lds8_2017_stack


#### NO NEED WITH ESPA###############################
### convert from digital number to meaningful units. using method "rad" which converts to top-of-atmosphere radiance (units: W*m-2*srad-1*m-1)

## Method 1 - manual
#dn2rad<-lds8_2017$CALRAD
#dn2rad
#lds8_2017_rad_man<-lds8_2017_stack*dn2rad$gain+dn2rad$offset

## Method 2 - automated with Rstoolbox 
#lds8_2017_rad<-radCor(lds8_2017_stack,metaData = lds8_2017,method="rad")
#lds8_2017_rad

#####################################################

### Claud Mask using ESPA pixel_qa layer ????????

pixel_qa<-raster("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/LC08_L1TP_204052_20170106_20170312_01_T1_pixel_qa.tif")
#ggR(pixel_qa)
plot(pixel_qa)

##############################################


###first plotting experience
plotRGB(ESPA_lds8_2017_stack, r=4,g=3,b=2, stretch="lin", ext=gnb[which(gnb$name_1 == "Bolama"),], axes=T)
#plot(gnb, add=T)
#ggRGB(ESPA_lds8_2017_stack,r=3,g=2,b=1, stretch ="hist", ext=gnb)

#hist(ESPA_lds8_2017_stack) ## Isto leva imeeeeeeeenso tempo a processar!

# cortar a multilayer ESPA com a shape da guine
crop1<-crop(ESPA_lds8_2017_stack,gnb[which(gnb$name_1 == "Bolama"),])
plotRGB(crop1,r=4,g=3,b=2, stretch="lin", axes=T, main="crop1")
#plot(crop1)


###### unsupervised class attempt

### abordagem raster package (3 different cassification)

values1_ESPA <- getValues(crop1)
i <- which(!is.na(values1_ESPA))
values1_ESPA <- na.omit(values1_ESPA)
head(values1_ESPA)
tail(values1_ESPA)

## kmeans classification 
E <- kmeans(values1_ESPA, 15, iter.max = 20, nstart = 10)
kmeans_raster <- raster(crop1)
kmeans_raster[i] <- E$cluster
plot(kmeans_raster, col=rainbow(20))

## clara classification 
clus <- clara(values1_ESPA,15,samples=20,metric="manhattan",pamLike=T)
clara_raster <- raster(crop1)
clara_raster[i] <- clus$clustering
plot(clara_raster)





######### trying to create a water mask 

qa<-raster("D:/Work/FCUL/Doutoramento/R/Mapping_coastal_Habitats_Guinea_Bissau/gnb_coastal/img/ESPA_L8_06012017/LC08_L1TP_204052_20170106_20170312_01_T1_pixel_qa.TIF")
ggR(qa)


qacs <- classifyQA(img = qa, confLayers = TRUE)
plot(qacs)

