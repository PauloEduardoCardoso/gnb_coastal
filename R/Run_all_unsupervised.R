#'# Load/Install Packages ##########################################################
kpacks <- c('raster', 'sp', 'rgdal', 'rgeos', 'ggplot2',
            'dplyr', 'foreign')
new.packs <- kpacks[!(kpacks %in% installed.packages()[ ,"Package"])]
if(length(new.packs)) install.packages(new.packs)
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)
#'##################################################################################

#' Function pack####################################################################
func <- grep("^f_", ls(), perl=TRUE, value = T)
#save(list=func, file='D:/Dropbox/programacao/duat_zambezia/rdata/functions7.RData')
load('D:/Programacao/RLandsat/functions7.RData')

#'# Projections ####################################################################
p.utm28n <- CRS("+init=epsg:32628") # UTM 28N Landsat Images
p.wgs84 <- CRS("+init=epsg:4326") # WGS84 Long Lat

#' Parameters ######################################################################
#scene <- 'LC82040522013331LGN00'
scene <- 'LC82040522013331LGN00' 
dir.work <- file.path('D:/Sig/Raster/landsat', scene)
dir.landsat <- 'dos1'
dir.data <- 'D:/Sig/Bissau/Cacheu/sig/vetor'
dir.sub <- 'sub'
pathto_dos1 <- file.path(dir.work, dir.landsat)

#' Layers
pntc <- readOGR(dsn = 'D:/Sig/Bissau/Cacheu/sig', layer = 'PNTC_UTM28N')
pntc_terr <- readOGR(dsn = 'D:/Sig/Bissau/Cacheu/sig', layer = 'PNTC_UTM28NTerrestre')
proj4string(pntc_terr) <- p.utm28n
pnctnz <- readOGR(dsn = 'D:/Sig/Vetor/Conservacao', layer = 'PNCantanhez_UTM28N')
bij_bol <- readOGR(dsn = 'D:/Sig/Bissau', layer = 'ae_sedimentos_utm28n')
#plot(band); plot(aeg, add = T)
plot(bij_bol)
#' Function pack ###################################################################
load('D:/Programação/RLandsat/Data/functions.RData')

sp::is.projected(pntc_terr)
#' Process K-means #################################################################
#ae <- aeg#[aeg$gr==i,]
stk_dos1 <- f_stkDOS1(roi = pntc_terr, fpath = pathto_dos1)
mask_ae <- f_createRoiMask(maskpoly = pntc_terr, maskvalue = NA, band = band)
stk_mask <- f_applmask(stk = stk_dos1, mask = mask_ae)
#stk_mask <- dropLayer(stk_mask, 1) # - Coastal blue
pca_obj <- f_pca(stk = dropLayer(stk_mask, 1), corr = F, comps = 3)
stk_pca <- pca_obj[[2]]
stk_pca
num.clss <- 50
ikmeans <- f_kmeans(stk = stk_model, ncl = num.clss, niter.max = 10,
                    nstarts = 10, algorithm = "Hartigan-Wong")
writeRaster(ikmeans, filename=file.path(dir.work, dir.sub,
                                        paste0('kmeans',
                                               num.clss,
                                               '_pntc_',
                                               scene,'.tif')),
            format="GTiff", datatype="INT1U", overwrite=TRUE)

writeRaster(stk_model
            ,filename=file.path(dir.work, dir.sub, paste0(scene,'.tif'))
            ,format="GTiff", bylayer=T
            , datatype="FLT4S", overwrite=TRUE)
writeRaster(stk_txtr
            ,filename=file.path(dir.work, dir.sub
                                , paste0('textura',scene,'.tif'))
            ,format="GTiff", bylayer=T
            , datatype="FLT4S", overwrite=TRUE)


rcl <- matrix(c(0, 6, 1, 6, 12, 2, 12, 90, 3),
              ncol = 3, byrow = TRUE)


