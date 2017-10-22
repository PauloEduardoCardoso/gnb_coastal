#' Deal with BQA band from Landsat Surface Reflectance Level-2 Science Data Product
#' using RSToolbox::classifyQA()

library(raster)
library(RStoolbox)
library(here) # https://github.com/jennybc/here_here

#'# Read a BQA Band
bqa <- raster('G:/satelite/landsat/LC082040522017010601T1/LC08_L1TP_204052_20170106_20170312_01_T1_pixel_qa.TIF')
#'# BQA classes
qacs <- classifyQA(img = bqa, confLayers = TRUE)
plot(qacs[['water']])

#'# Projections ####################################################################
p.utm28n <- CRS("+init=epsg:32628") # UTM 28N Landsat Images
p.wgs84 <- CRS("+init=epsg:4326") # WGS84 Long Lat

#' Parameters ######################################################################
#' When reading surface reflectances bands
#scene1 <- 'LC82040522013331LGN00'
#scene2 <- 'LC82040522013331LGN00' 
#scene3 <- 'LC82040522013331LGN00' 
#dir.landsat <- 'dos1'
#dir.data <- 'D:/Sig/Bissau/Cacheu/sig/vetor'
#dir.sub <- 'sub'
path_to_sr <- file.path(dir.work, dir.landsat)

#' Processed bands and geo space ##############################
dir.work <- file.path('D:/Dropbox/Bissau/bijagos/ecognition/img')

#' Auxiliar Layers #################################################################
#' ROI for sediment analysis from Bijagos 
bij_bol <- rgdal::readOGR(dsn = 'D:/Sig/Bissau', layer = 'ae_sedimentos_utm28n')
plot(bij_bol)

#' Function pack ###################################################################
load('D:/Programação/RLandsat/Data/functions.RData')

#' Read TIF
stk_1 <- raster::stack(file.path(dir.work, 'LT05_19860218.tif'))
stk_2 <- raster::stack(file.path(dir.work, 'LT05_19860407.tif'))

#' Extract Latent Variables
#' tasseledCAP
tc1 <- RStoolbox::tasseledCap(stk_1, sat = "Landsat5TM")
#plot(tc1)
raster::writeRaster(tc1, filename = file.path(dir.work, 'tc1.tif')
                    , options = c("INTERLEAVE=BAND", "TFW=YES")
                    , overwrite = TRUE , datatype = 'INT2S')

tc2 <- RStoolbox::tasseledCap(stk_2, sat = "Landsat5TM")
#plot(tc2)
raster::writeRaster(tc2, filename = file.path(dir.work, 'tcap2_.tif')
                    , options = c("INTERLEAVE=BAND", "TFW=YES")
                    , overwrite = TRUE , datatype = 'INT2S'
                    , bylayer = T)

#' Process K-means #################################################################
#ae <- aeg#[aeg$gr==i,]
mask_ae <- f_createRoiMask(maskpoly = pntc_terr, maskvalue = NA, band = band)
stk_mask <- f_applmask(stk = stk_dos1, mask = mask_ae) # still to find the function code
#stk_mask <- dropLayer(stk_mask, 1) # - Coastal blue
