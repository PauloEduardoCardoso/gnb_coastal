#' Deal with BQA band from Landsat Surface Reflectance Level-2 Science Data Product
#' using RSToolbox::classifyQA()

library(raster)
library(RStoolbox)
library(here) # https://github.com/jennybc/here_here

#'# Read a BQA Band
bqa <- raster('G:/satelite/landsat/LC08_L1TP_204052_20140420_20170423_01_T1/LC08_L1TP_204052_20140420_20170423_01_T1_BQA.TIF')

#'# BQA classes
qacs <- classifyQA(img = bqa, confLayers = TRUE)

#'# Confidence levels
qacs_conf <- classifyQA(img = qa, confLayers = TRUE)