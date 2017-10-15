#' Apply ROI crop to DOS1 bands
#' Song et al 2000: DOS1 Works just fine for land change detection
#' ! call internal f_substrBand function

f_stkDOS1 <- function(roi = ae1, fpath = pathto_dos1, crop = F, scale=0.0001){
  if(!exists('f_substrBand')) stop ('missing f_substrBand function')
  bands <- list.files(fpath, full.names = T,
                      pattern = '.TIF$|.tif$|.tiff$') 
  stopifnot(length(bands) != 0)
  i.stk <- stack(bands)
  if(crop == T) {i.stk <- crop(i.stk, roi)}
  if(scale != 1){i.stk <- i.stk * scale}
  names(i.stk) <- paste0('b', f_substrBand(bands), '_ae')
  return(i.stk)
}

#stk_dos1 <- f_stkDOS1(roi = duat, fpath = pathto_dos1, crop = F)
#stk_1 <- crop(stk_dos1, ae)
#summary(stk_1[[1]])
#plot(stk_dos1)

