#' PCA on Bands 1:7 and retain first 3 Components with > 99% expl var --------------
f_pca <- function(stk = stk, corr = F, comps = 3){
  #any(is.na(getValues(stk_topoc)) == T)
  stki <- reclassify(stk, matrix(c(NA, -0.01), nrow = 1))  
  #stki <- stk[is.na(stk)] <- 0.01
  pcalist <- list()
  xdf <- as.data.frame(stki)
  pca1 <-  princomp(~ ., xdf, cor = corr, na.action=na.exclude) 
  pcalist[[1]] <- pca1
  pcastk <- stack()
  for(i in 1:comps){
    pcax <- matrix(pca1$scores[ , i], nrow = nrow(stk), ncol = ncol(stk),
                   byrow = TRUE)
    pcax <- raster(pcax, xmn = stk@extent@xmin, ymn = stk@extent@ymin,
                   xmx = stk@extent@xmax, ymx = stk@extent@ymax,
                   crs = CRS(proj4string(band)))
    pcastk <- addLayer(pcastk, pcax)
  }
  pcalist[[2]] <- pcastk
  return(pcalist)
}

#remove(stk, corr, comps)
f_pca1 <- function(stk = stk, corr = F, comps = 3){
  stki <-  reclassify(stk, matrix(c(NA, -0.01), nrow = 1))  
  pcalist <- list()
  xdf <- as.data.frame(stk)
  pca1 <-  princomp(na.omit(xdf), cor = corr) 
  pcalist[[1]] <- pca1
  pcastk <- stack()
  for(i in 1:comps){
    iNA <- rep(NA, length(xdf[ ,1]))
    iNA[!is.na(xdf[ ,1])] <- pca1$scores[ ,i]  
    #create raster output
    ##pcax <- raster(stk) # create an empty raster with same extent than stack  
    ##pcax <- setValues(pcax, iNA) # fill the empty raster with the class results  
    ##i.kraster
    pcax <- matrix(iNA, nrow = nrow(stk), ncol = ncol(stk),
                   byrow = TRUE)
    pcax <- raster(pcax, xmn = stk@extent@xmin, ymn = stk@extent@ymin,
                   xmx = stk@extent@xmax, ymx = stk@extent@ymax,
                   crs = CRS(proj4string(mask_ae)))
    pcastk <- addLayer(pcastk, pcax)
  }
  pcalist[[2]] <- pcastk
  return(pcalist)
}

#'# Provide the stack object for analysis
#pca_obj <- f_pca(stk = stk_dos1, corr = F, comps = 3)
#plot(pca_obj[[2]])

#pca_obj1 <- f_pca1(stk = stk_mask, corr = F, comps = 3)
#stk_pca <- pca_obj[[2]]
#stk_pca1 <- pca_obj1[[2]]
#plot(pca_obj[[1]])

#summary(pca_obj[[1]])
#summary(pca_obj1[[1]])
#plot(stk_pca1);

#microbenchmark(
#  f_pca1(stk = stk_mask, corr = F, comps = 3),
#  f_pca(stk = stk_mask, corr = F, comps = 3),
#  times = 10L
#)
