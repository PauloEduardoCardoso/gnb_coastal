#' Sediment topography

#'# Packages
kpacks <- c('raster', 'sp', 'rgdal', 'RStoolbox', 'cluster')
new.packs <- kpacks[!(kpacks %in% installed.packages()[ ,"Package"])]
if(length(new.packs)) install.packages(new.packs)
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)

#'## import shape guine-bissau
gnb <- readOGR("D:/Dropbox/programacao/gnb_coastal/gis", "gnb_utm28n")
#plot(gnb)

# L5
dirs <- c(
  'G:/satelite/landsat/LT052040521986021801T1'
  )

dirs8<- c(
  #'G:/satelite/landsat/LC082040522016120501T1'
  #,'G:/satelite/landsat/LC082040522017010601T1'
  #,'G:/satelite/landsat/LC08_L1TP_204052_20141114_20170417_01_T1'
  # ,'G:/satelite/landsat/LC08_L1TP_204052_20140420_20170423_01_T1' # demasiada turbidez <600
)

sr5 <- list.files(dirs, pattern = glob2rx("*sr_band5*tif$"), full.names = T)
stk <- stack()
for(i in sr5){
  ir <- raster(i)
  ir <- raster::crop(ir, gnb[which(gnb$name_1 == "Bolama"), ])
  stk <- raster::addLayer(stk, ir)
}
sr5
plot(stk)

m <- c(-Inf, 250, 0 # water
       ,250, Inf, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)

beginCluster()
water <- raster::clusterR(stk, # Parallel
                          reclassify, args=list(rcl=rclmat, include.lowest=FALSE, right=TRUE)
)
raster::endCluster()

plot(water, main="water mask")

land0 <- stk[[1]]
land0[] <- 0
land <- mask(land0, gnb#[which(gnb$name_1 == "Bolama"), ]
             , updatevalue = 1, updateNA = T)
plot(land, main="land mask")

landwat <- land*water
plot(landwat, main = 'sediment mask')
writeRaster(landwat
            , filename = file.path('G:/satelite/coastalGNB/sedimentos/gnb_sed_19860218.tif')
            , options = c("TFW=YES")
            , overwrite = TRUE, datatype = 'INT1U'
)


#'## abordagem raster package (3 different cassification)
stk_sed <- cropstk * landwat
plot(stk_sed[[1]], main="stk 1")

#' EWI : Wang, S., Hasan, M., Baig, A., Zhang, L., Member, S., Jiang, H., & Ji, Y. (2015).
#' A Simple Enhanced Water Index (EWI) for Percent Surface Water Estimation Using Landsat Data.
#' IEEE Geoscience and Remote Sensing Letters, 8(1), 90–97.
#' ( "band3" - "band6" + 0.1 ) / ( ( "band3" + "band6" ) * ( ( "band5" - "band4" ) / ( "band5" + "band4" ) + 0.5) )
#' 
ewi0 <- raster('G:/satelite/ewi_20140420.tif')
ewi0 <- raster::crop(ewi0, gnb[which(gnb$name_1 == "Bolama"), ])
m1 <- c(-Inf, -0.01, 0 # land
       ,-0.01, 0.35, 1,   # sediment
       0.35, +Inf, 0   # water
       )
rclmat1 <- matrix(m1, ncol=3, byrow=TRUE)

raster::beginCluster()
water <- raster::clusterR(ewi0, # Parallel
                          reclassify, args=list(rcl=rclmat1, include.lowest=FALSE, right=TRUE)
)
raster::endCluster()
plot(water)

writeRaster(water
            , filename = file.path('G:/satelite/coastalGNB/sedimentos/gnb_sed_ewi_20140420.tif')
            , options = c("TFW=YES")
            , overwrite = TRUE, datatype = 'INT1U'
)
