#'# Load/Install Packages ##########################################################
kpacks <- c('Kendall', 'ncdf4', 'forecast', 'SDMTools', 'bcp',
            'tidyverse', 'foreign', 'lubridate')
new.packs <- kpacks[!(kpacks %in% installed.packages()[ ,"Package"])]
if(length(new.packs)) install.packages(new.packs)
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)
#'##################################################################################

list <- list.files('G:/satelite/landsat/espa_download', pattern = '.tar.gz'
                   , recursive = T)


dfs <- data.frame('scene'=substr(sub('.*/', '', list), 1,22), stringsAsFactors = F)
dfs %>%
  dplyr::filter(grepl("L", scene)) %>%
  dplyr::mutate(date = ymd(substr(scene, 11, 18))) %>%
  arrange(date)

install.packages("greenbrown", repos="http://R-Forge.R-project.org")
library(greenbrown)

data(ndvi) # load the time series
plot(ndvi) # plot the time series

# calculate trend (default method: TrendAAT)
trd <- Trend(ndvi)
trd

data(ndvimap) # load the example raster data
ndvimap # information about the data
plot(ndvimap, 8, col=brgr.colors(50))

> # calculate trend on the raster dataset using annual maximum NDVI
trendmap <- TrendRaster(ndvimap, start=c(1982, 1), freq=12, method="AAT", breaks=1, funAnnual=max)
plot(trendmap, col=brgr.colors(20), legend.width=2) # this line will produce figure 2:
