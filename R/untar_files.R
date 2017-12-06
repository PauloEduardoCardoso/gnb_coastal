library(utils)
dir <- 'G:/satelite/landsat/espa_download/espa-pauloeducardoso@gmail.com-11232017-173039-508'
dir_out <- 'G:/satelite/landsat/espa_download/'
tars <- list.files(dir, pattern = '.tar.gz', full.names = F)
untar(file.path(dir, tars[1]), list=T, exdir = dir_out)

      