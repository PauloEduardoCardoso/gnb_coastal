# Mapping coastal Habitats of Guinea Bissau

<img src="https://github.com/PauloEduardoCardoso/gnb_coastal/blob/master/img/coastal_gnb_20170106.png" width="600">

Notes in English to avoid RStudio conflict with non UTF encoding (PT).

#### Suggestion of approach
I'd suggest us to work with functions from RSToolbox from Benjamin Leutner, particularly unsuperClass() to start.

#### Git ssh key
https://stackoverflow.com/questions/1595848/configuring-git-over-ssh-to-login-once

***
#### Landsat Scenes
We will explore Landsat Surface Reflectance Level-2 Science Data Products.
Details here:
https://landsat.usgs.gov/landsat-surface-reflectance-data-products
 
Ideally we'll work with Landsat scenes from Tier 1 collection
More about Tier collections here:
https://landsat.usgs.gov/what-are-landsat-collection-1-tiers
 
A Technical Guide for USGS products (focus on COllection 1)
https://above.nasa.gov/pdfs/Landsat_Surface_Reflectance_ABoVE_21Apr2017.pdf
 
The best and last scene capturing a large fraction of exposed sediments is:

Scene ID         | LC08_L1TP_204052_20170106_20170312_01_T1
---------------- | ----------------------------------------
Acquisition Date | 06-JAN-17
Path             | 204
Row              | 52

#### Important to clarify
Understant product levels, particularly when delivered from bulk download order of obtained directly from ESPA notification

##### Typical bulk order T1 product: LC08_L1TP_204052_20170106_20170312_01_T1_B1

##### Typical ESPA download T1 product: LC08_L1TP_204052_20170106_20170312_01_T1_sr_band1

#### Important to clarify
Understant product levels, particularly when delivered from bulk download order of obtained directly from ESPA notification

- Typical bulk order (T1 product): LC08_L1TP_204052_20170106_20170312_01_T1_B1.tif
- Typical ESPA download (T1 product): LC08_L1TP_204052_20170106_20170312_01_T1_sr_band1.tif

From LEDAPS Product Manual v8.0 (https://goo.gl/92n5Nb)
Changes implemented in 2017-03-10: 
"Edited for new quality assurance (QA) band information in Collection 1 (cfmask, cfmask_conf replaced by pixel_qa.) L1 quality band (bqa) removed from standard output. Per-pixel sensor/solar angle bands (derived from band 4) now provided with each product. toa_qa replaced by radsat_qa.""

***
#### Water/Land discrimination

##### simple
- From LaSRC pixel_qa band
- MNDWI (very poor)
##### More complex
- Classification of Potential Water Bodies Using Landsat 8 OLI and a Combination of Two Boosted Random Forest Classifiers (https://goo.gl/Xxh7gw)

- Target Detection Method for Water Mapping Using Landsat 8 OLI/TIRS Imagery (https://goo.gl/RkD7Ss)