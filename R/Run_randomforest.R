#' Supervised classification with Random forest from caret

#' Signature development  ----------------------------------------------------------
proj4string(train) #<- p.utm28n # Asign projection
# Atencao! usar o stk_model ou o RF para a cosntrucao das assinaturas!
datasets <- f_sign(stk = stk_model, mask = NULL, train = train
                   , class = 'C_info', subsets = F)
head(datasets)
datasets$classe <- as.factor(datasets$classe)
#set.seed(998)

#' Subset training classes ---------------------------------------------------------
inTraining <- caret::createDataPartition(datasets$classe, p = .80, list = FALSE)
training <- datasets[ inTraining, ]
testing  <- datasets[-inTraining, ]
as.data.frame(table(training$classe))
head(training)

#' Random Forest model with caret --------------------------------------------------
fitControl <- caret::trainControl(
  ## 5-fold CV
  method = "repeatedcv"
  ,number = 5
  ## repeated n times
  ,repeats = 5
  ,allowParallel = TRUE)

cluster1 <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster1)
#set.seed(825)
rfFit1 <- caret::train(classe ~ ., data = training
                       ,method = "rf"
                       ,tuneLength = 5
                       #,tuneGrid=grid_c
                       ,metric = "Accuracy"
                       ,trControl = fitControl
                       ## This last option is actually one
                       ## for gbm() that passes through
                       ,verbose = FALSE
)
rfFit1
stopCluster(cluster1)

#' Predict Random Forest------------------------------------------------------------
rf_mod <- raster::predict(stk_modelRF, rfFit1,  type='raw')

#' Confusion matrix ----------------------------------------------------------------
rf_test <- raster::predict(rfFit1, newdata = testing)
matrizc<- caret::confusionMatrix(data = rf_test, testing$classe)
matrizc

#' RF Model Outputs ----------------------------------------------------------------
print(rfFit1$finalModel)
varImp(rfFit1)
#' Model Plots
plot(varImp(rfFit1))
plot(rfFit1)
plot(rfFit1$finalModel)
#library('rattle')
#fancyRpartPlot(rfFit1$finalModel)

#' Export Random Forest surface ----------------------------------------------------
writeRaster(rf_mod
            , filename=file.path('G:/Sig/raster/landsat/LC81660712016250'
                                 , 'lcover_duat2016_6.tif')
            , format="GTiff", datatype="INT1U", overwrite=TRUE)
