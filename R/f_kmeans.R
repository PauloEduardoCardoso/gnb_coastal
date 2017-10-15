f_kmeans1 <- function(stk = stk, ncl = num.clss, niter.max = 5, nstarts = 5){
  xdf <- as.data.frame(stk)
  #xdf <- scale(xdf)
  ikm <- kmeans(na.omit(xdf), ncl, iter.max = niter.max,
                nstart = nstarts, algorithm = "Hartigan-Wong")
  iNA <- rep(NA, length(xdf[,1]))
  iNA[!is.na(xdf[,1])] <- ikm$cluster  
  #create raster output
  i.kraster <- raster(stk) # create an empty raster with same extent than stack  
  i.kraster <- setValues(i.kraster, iNA) # fill the empty raster with the class results  
  i.kraster
}

#num.clss <- 9
#ikmeans <- f_kmeans1(stk = stk_pca1, ncl = num.clss, niter.max = 15, nstarts = 15)
#plot(ikmeans)
