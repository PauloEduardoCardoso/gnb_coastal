#' Function f_vegind to create vegetation index

function(stk = stk){
  inbr <- (stk[[4]]-stk[[6]]) / (stk[[4]]+stk[[6]])
  names(inbr) <- 'nbr'
  #indexlist <- 'nbr'
  isavi <- (1.5*(stk[[4]]-stk[[3]])) / (stk[[4]]+stk[[3]]+0.5)
  names(isavi) <- 'savi'
  indvi <- (stk[[4]]-stk[[3]]) / (stk[[4]]+stk[[3]])
  names(indvi) <- 'ndvi'
  ievi <- 2.5 *  (stk[[4]] - stk[[3]]) / (stk[[4]] + 6 * stk[[3]] - 7.5 *stk[[1]] + 1)
  names(ievi) <- 'evi'
  indmi <- (stk[[5]]-stk[[6]]) / (stk[[5]]+stk[[6]])
  names(indmi) <- 'ndmi'
  vegstk <- stack(inbr, isavi, indvi, ievi, indmi)
  return(vegstk)
}
