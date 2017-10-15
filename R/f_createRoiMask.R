#' Function f_CreateRoiMask

function(maskpoly = maskpoly, maskv = 1, band = band){
  i.band <- band
  if(is.na(i.band@crs)) stop('Image miss crs information')
  #stopifnot(!is.na(i.band@crs)) # Check raster for a projection
  ## Check polyg for a projection
  if(is.na(sp::proj4string(maskpoly))) stop('polygon miss crs information')
  ## Create Extent object from ae shapefile
  ## EPSG and reprojection of polygon
  if(!compareCRS(band, maskpoly)) stop ('crs missmatch')
  #if() {
  #maskpoly <- sp::spTransform(maskpoly, CRS(proj4string(i.band)))
  #}
  #i.roi <- extent(maskpoly)
  # Crop Landsat Scene to AE extent
  #band.1 <- i.band # Raster AE: resolucao 30m (Landast)
  #band.1[] <- 1 # Defalt value
  i.bandae <- raster::crop(i.band, maskpoly) # Crop band to AE Extent
  i.bandae[] <- 1
  #i.bandae <- crop(i.band, maskpoly) # Crop band to AE Extent
  ## 2nd: Create the Mask raster to the croped band extent
  #ae.r <- i.bandae # Raster AE: resolucao 30m (Landast)
  #ae.r[] <- 1 # Defalt value
  ## Overlay AE poly to AE Extent raster
  ## Mask will have 1 and NA values
  msk.ae <- raster::mask(i.bandae, maskpoly, updatevalue=NA)
  #dataType(mask_ae) <- "INT1U" 
  ## Evaluate rasters
  #stopifnot(compareRaster(msk.ae, i.bandae)) 
  return(msk.ae)
}
