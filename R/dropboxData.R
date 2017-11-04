#install.packages('rdrop2')
#install.packages('httpuv')
library(rdrop2)
library(httpuv)
library(dplyr)
drop_auth()
# save the tokens, for local/remote use
token <- drop_auth()
saveRDS(token, file = "path/to/savetoken/dropb_token.rds")

drop_dir('/Bissau/papers/coastal_habitats/r')
drop_download("/bissau/papers/coastal_habitats/r/run_all_unsupervised.r")
#drop_download('/bissau/papers/coastal_habitats/r/unsupervised_cluster.r')
getwd()
