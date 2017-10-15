#' Manage band names

f_substrBand <- function(x){
  #if(nchar(x)>4){
  as.numeric(substr(x, nchar(x)-4, nchar(x)-4))
  #}
}
