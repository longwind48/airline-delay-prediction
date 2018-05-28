# Master script to run helper scripts
# Authors: Traci Lim, Willian Skinner, Yi Luo

# Options ================================================================================
trainingSizeSmall <- TRUE

# 1.0 Load libraries and functions ===========================================================
source("scripts/loadLibraries.R")
source("functions/trainModel.R")
source("functions/lookupAirportData.R")
source("functions/preprocess.R")
source("functions/clean.R")
source("functions/engineerFeatures.R")
source("functions/splitIntoTrainAndTest.R")
source("functions/analyzeCausesOfDelay.R")
source("functions/UnivariateAnalysis.R")
source("functions/multivariateAnalysis.R")
source("functions/predictDelays.R")
source("functions/max_num_flights.R")
source("functions/displayDelayProbabilities.R")
source("functions/appendAirportData.R")
source("functions/resample.R")
source("functions/resampleCustom.R")
source("functions/toMinutesAfterMidnight.R")
source("functions/numFlightsIn2017FromAirport.R")

# 2.0 Import and preprocess data =============================================================

# Load data from files and select raw data set
if(trainingSizeSmall) {
  load("data/Flight_Data_2017_Sampled.RData")
  set.seed(7)
  raw.data <- data_2017_100000
  numTrain <- 7000
  numTest <- 3000
} else {
  load("data/Flight_Data_2017.RData")
  set.seed(7)
  raw.data <- sample_n(data_2017, 300000)
  numTrain <- 70000
  numTest <- 30000
}

# Preprocess data to set data types, add lats and longs, and break response into classes
preprocessed.data <- preprocess(raw.data)

# Deal with missing values
clean.data <- clean(preprocessed.data)

# Select features and split dataset
data <- engineerFeatures(clean.data, ohe=FALSE)
data.list <- splitIntoTrainAndTest(data, fractionToTrain = 0.89)
traindf <- data.list[["train"]]
traindf <- resampleCustom(traindf, numTrain)
testdf <- data.list[["test"]]
testdf <- sample_n(testdf, numTest)

# Select features, perform one-hot-encoding, and split dataset
ohe.data <- engineerFeatures(clean.data, ohe=TRUE)
ohe.data.list <- splitIntoTrainAndTest(ohe.data, fractionToTrain = 0.89)
ohe.traindf <- ohe.data.list[["train"]]
ohe.traindf <- resampleCustom(ohe.traindf, numTrain)
ohe.testdf <- ohe.data.list[["test"]]
ohe.testdf <- sample_n(ohe.testdf, numTest)

# 3.0 Analyze data ===========================================================================
# Load mainForAnalysis.R for analysis

# 4.0 Train models ===========================================================================
control <- trainControl(
  method = "cv",
  number = 5,
  savePredictions = TRUE,
  verboseIter = TRUE,
  returnData = FALSE,
  returnResamp = "all",                       # save losses across all models
  classProbs = TRUE,                          # set to TRUE for AUC to be computed
  summaryFunction=multiClassSummary,
  allowParallel = TRUE
)
# -> The function trainControl can be used to specifiy the type of resampling,
#    in this case, 5-fold cross validation.
# metric <- "Accuracy" 
metric <- "Balanced_Accuracy" 

# Parallel Processing
# -> https://github.com/tobigithub/caret-machine-learning/wiki/caret-ml-parallel
# -> caret supports the parallel processing capabilities of the parallel package. 
# -> allowParallel which tells caret to use the cluster that we've registered in the previous step.
library(parallel)
nCores <- detectCores(logical = FALSE)
nThreads <- detectCores(logical = TRUE)
cat("CPU with",nCores,"cores and",nThreads,"threads detected.\n")

# To train models using parallel processing, use following code:
library(doParallel)
cl <- makeCluster(nCores-1)
registerDoParallel(cl)
# train CODE
stopCluster(cl)
registerDoSEQ()

# 4.1 CART =====================================================================================
set.seed(7)
system.time(fit.cart <- caret::train(ARR_DEL15~., data=traindf, method="rpart",
                                     parms = list(split = "information"), #or 'information'
                                     metric=metric, trControl=control, tuneLength = 10))
set.seed(7)
system.time(fit.cart2 <- caret::train(ARR_DEL15~., data=traindf, method="rpart",
                                      parms = list(split = "gini"), #or 'information'
                                      metric="F1", trControl=control, tuneLength = 10))
# -> The final value used for the model was cp = 0.0002822467.
# -> 155.74 
set.seed(7)
system.time(fit.cart1 <- caret::train(ARR_DEL15~., data=traindf, method="rpart",
                                      parms = list(split = "gini"), #or 'information'
                                      metric=metric, trControl=control, tuneLength = 10))
# -> The final value used for the model was cp = 0.001809524.
# -> 40.34 

# Get test-set scores
predictions.cart<-predict(fit.cart,testdf)
caret::confusionMatrix(predictions.cart, testdf$ARR_DEL15)
predictions.cart1<-predict(fit.cart1,testdf)
caret::confusionMatrix(predictions.cart1, testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
predictions.cart1.probs<-predict(fit.cart1, newdata = testdf, type='prob')$no_delay

# Save models
save(fit.cart, file = "models/fit.cart_data_2017_resampled_balancedacc.RData")
save(fit.cart1, file = "models/fit.cart1_data_2017_resampled_balancedacc.RData")

# 4.2 Logistic Regression =============================================================================
set.seed(7)
system.time(fit.logit <- caret::train(ARR_DEL15~., data=ohe.traindf, method="glm", family="binomial",
                                      metric=metric, trControl=control))
# -> 385.14 
set.seed(7)
system.time(fit.logitreg <- caret::train(ARR_DEL15~., data=ohe.traindf, method="regLogistic", family="binomial",
                                         metric=metric, trControl=control))
# -> The final values used for the model were cost = 2, loss = L1 and epsilon = 0.001.
# -> 339.44

set.seed(7)
system.time(fit.logitreg1 <- caret::train(ARR_DEL15~., data=ohe.traindf, method="regLogistic", family="binomial",
                                          metric=metric, trControl=control, tuneLength=5))
# -> The final values used for the model were cost = 0.25, loss = L1 and epsilon = 1.
# -> 316.69

set.seed(7)
system.time(fit.logitreg2 <- caret::train(ARR_DEL15~., data=ohe.traindf, method="regLogistic", family="binomial",
                                          metric=metric, trControl=control, tuneGrid=data.frame(.cost = 0.25, .loss = "L1", .epsilon = 1)))
# -> The final values used for the model were cost = 0.25, loss = L2_primal and epsilon = 1e-04.
# -> 9.72

# Get test-set scores
predictions.logit<-predict(fit.logit,ohe.testdf)
caret::confusionMatrix(predictions.logit, ohe.testdf$ARR_DEL15)
predictions.logitreg<-predict(fit.logitreg,ohe.testdf)
caret::confusionMatrix(predictions.logitreg, ohe.testdf$ARR_DEL15)
predictions.logitreg1<-predict(fit.logitreg1,ohe.testdf)
caret::confusionMatrix(predictions.logitreg1, ohe.testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
predictions.logit.probs<-predict(fit.logit,ohe.testdf, type='prob')$no_delay
predictions.logitreg1.probs<-predict(fit.logitreg1,ohe.testdf, type='prob')$no_delay

# Save models
load("C:/Users/longwind48/Desktop/fit.logit_data_2017_resampled_balancedacc.RData")
save(fit.logit, file = "C:/Users/longwind48/Desktop/fit.logit_data_2017_resampled_balancedacc.RData")
save(fit.logitreg, file = "models/fit.logitreg_data_2017_resampled_balancedacc.RData")
save(fit.logitreg1, file = "models/fit.logitreg1_data_2017_resampled_balancedacc.RData")
save(fit.logitreg2, file = "models/fit.logitreg2_data_2017_resampled_balancedacc.RData")

# 4.3 C5.0 ============================================================================================

grid.c50 <- expand.grid( .winnow = c(TRUE,FALSE), .trials=c(5,6), .model="tree" )

system.time(fit.C5.0 <- caret::train(ARR_DEL15~., data=traindf,
                                     method="C5.0", tuneGrid=grid.c50, metric=metric, trControl=control))
# -> The final values used for the model were trials = 10, model = tree and winnow = FALSE.
# -> 244.55 
set.seed(7)
system.time(fit.C5.01 <- caret::train(ARR_DEL15~., data=traindf, tuneGrid=grid.c50,
                                      method="C5.0", metric=metric, trControl=control))
# -> The final values used for the model were trials = 6, model = tree and winnow = FALSE.
# -> 179.81
set.seed(7)
system.time(fit.C5.01 <- caret::train(ARR_DEL15~., data=traindf, tuneGrid=grid.c50,
                                      method="C5.0", metric=metric, trControl=control))
# -> The final values used for the model were trials = 8, model = tree and winnow = FALSE.
# -> 136.87 


# Get test-set scores
predictions.c50<-predict(fit.C5.0,testdf)
caret::confusionMatrix(predictions.c50, testdf$ARR_DEL15)
predictions.c501<-predict(fit.C5.01,testdf)
caret::confusionMatrix(predictions.c501, testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
predictions.c501.probs<-predict(fit.C5.01,testdf, type='prob')$no_delay

# Save models
save(fit.C5.01, file = "models/fit.C5.01_data_2017_resampled_balancedacc.RData")
# -> It was first tuned on 1,10,20 trials, then 6,8,10,12 trials, then 5,6 trials.

# 4.4 GBM (Stocastic Gradient Boosting) ===================================================================
set.seed(7)
system.time(fit.gbm<- caret::train(ARR_DEL15~., data=ohe.traindf, method="gbm", 
                                   metric=metric, trControl=control))
# -> The final values used for the model were n.trees = 150, interaction.depth = 3, shrinkage = 0.1 and n.minobsinnode = 10.
set.seed(7)
system.time(fit.gbm1<- caret::train(ARR_DEL15~., data=ohe.traindf, method="gbm", 
                                    metric=metric, trControl=control,
                                    tuneGrid=data.frame(.n.trees = 150, .interaction.depth = 3, .shrinkage = 0.1,
                                                        .n.minobsinnode = 10)))
set.seed(7)
system.time(fit.gbm.300k<- caret::train(ARR_DEL15~., data=ohe.traindf, method="gbm", 
                                        metric=metric, trControl=control,
                                        tuneGrid=data.frame(.n.trees = 150, .interaction.depth = 3, .shrinkage = 0.1,
                                                            .n.minobsinnode = 10)))
# Get test-set scores
predictions.gbm<-predict(fit.gbm,ohe.testdf)
caret::confusionMatrix(predictions.gbm, ohe.testdf$ARR_DEL15)
predictions.gbm1<-predict(fit.gbm1,ohe.testdf)
caret::confusionMatrix(predictions.gbm1, ohe.testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
predictions.gbm.probs<-predict(fit.gbm,ohe.testdf, type='prob')$no_delay
predictions.gbm1.probs<-predict(fit.gbm1,ohe.testdf, type='prob')$no_delay

# Save models
save(fit.gbm, file = "models/fit.gbm_data_2017_resampled_balancedacc.RData")
save(fit.gbm1, file = "models/fit.gbm1_data_2017_resampled_balancedacc.RData")
save(fit.gbm.300k, file = "models/fit.gbm.300k_data_2017_resampled_balancedacc.RData")

# 4.5 eXtreme Gradient Boosting ==========================================================================
xgbgrid <- expand.grid(
  nrounds = 250, #250
  eta = 0.2, #0.2
  max_depth = 2, #2
  gamma = 0.5, #0.5
  colsample_bytree = 0.8,
  min_child_weight = 1,
  subsample = 1
)
set.seed(7)
system.time(fit.xgb<- caret::train(ARR_DEL15~., data=traindf, method="xgbTree", 
                                   metric=metric, trControl=control))
# ->The final values used for the model were nrounds = 100, max_depth = 2, eta = 0.3, gamma = 0, colsample_bytree= 0.8, min_child_weight = 1 and subsample = 1.
# -> 1234.50

set.seed(7)
system.time(fit.xgb1<- caret::train(ARR_DEL15~., data=traindf, method="xgbTree", 
                                    metric=metric, trControl=control, tuneLength=5))
# -> The final values used for the model were nrounds = 250, max_depth = 5, eta = 0.4, gamma = 0, colsample_bytree= 0.6, min_child_weight = 1 and subsample = 0.5.
# -> fit.xgb1:  2057.39 
set.seed(7)
system.time(fit.xgb2 <- caret::train(ARR_DEL15 ~ ., data = ohe.traindf, trControl = control,
                                     tuneGrid = xgbgrid, metric = metric, method = "xgbTree",
                                     verbose = 1, num_class = 2))
set.seed(7)
system.time(fit.xgb3<- caret::train(ARR_DEL15~., data=traindf, method="xgbTree", 
                                    metric=metric, trControl=control, tuneLength=10))
# -> fit.xgb3 27270.56
set.seed(7)
system.time(fit.xgb4<- caret::train(ARR_DEL15~., data=ohe.traindf, method="xgbTree", 
                                    metric=metric, trControl=control, tuneGrid=xgbgrid))
set.seed(7)
system.time(fit.xgb.300k<- caret::train(ARR_DEL15~., data=ohe.traindf, method="xgbTree", 
                                        metric=metric, trControl=control, tuneGrid=xgbgrid))

fit.xgb1$bestTune
plot(fit.xgb1)

# Get test-set scores
predictions.xgb<-predict(fit.xgb,testdf)
caret::confusionMatrix(predictions.xgb, testdf$ARR_DEL15)
predictions.xgb1<-predict(fit.xgb1,testdf)
caret::confusionMatrix(predictions.xgb1, testdf$ARR_DEL15)
predictions.xgb2<-predict(fit.xgb2,testdf)
caret::confusionMatrix(predictions.xgb2, testdf$ARR_DEL15)
predictions.xgb3<-predict(fit.xgb3,testdf)
caret::confusionMatrix(predictions.xgb3, testdf$ARR_DEL15)
predictions.xgb4<-predict(fit.xgb4,ohe.testdf)
caret::confusionMatrix(predictions.xgb4, ohe.testdf$ARR_DEL15)
predictions.xgb.300k<-predict(fit.xgb.300k,ohe.testdf)
caret::confusionMatrix(predictions.xgb.300k, ohe.testdf$ARR_DEL15)
roc(ohe.testdf$ARR_DEL15, predictions.xgb.300k.probs)

# Retrieve predictions in probabilities, for ROC plots
predictions.xgb1.probs<-predict(fit.xgb1,testdf, type='prob')$no_delay
predictions.xgb2.probs<-predict(fit.xgb2,testdf, type='prob')$no_delay
predictions.xgb4.probs<-predict(fit.xgb4,ohe.testdf, type='prob')$no_delay
predictions.xgb.300k.probs<-predict(fit.xgb.300k,ohe.testdf, type='prob')$no_delay

# Save models
save(fit.xgb2, file = "models/fit.xgb2_data_2017_resampled_balancedacc.RData")
save(fit.xgb1, file = "models/fit.xgb1_data_2017_resampled_balancedacc.RData")
save(fit.xgb4, file = "models/fit.xgb4_data_2017_resampled_balancedacc.RData")
save(fit.xgb.300k, file = "models/fit.xgb.300k_data_2017_resampled_balancedacc.RData")

# 4.6 All Other Models ====================================================================================
nnetGrid <-  expand.grid(size = seq(from = 5, to = 10, by = 1),
                         decay = seq(from = 0.02, to = 0.1, by = 0.02))

set.seed(7)
system.time(fit.nnet <- caret::train(ARR_DEL15~., data=ohe.traindf, method="nnet", tuneLength=5,
                                     metric=metric, trControl=control))
# -> The final values used for the model were size = 1 and decay = 0.1.
# -> 49.63
set.seed(7)
system.time(fit.nnet1 <- caret::train(ARR_DEL15~., data=ohe.traindf, method="nnet", tuneGrid=nnetGrid,
                                     metric=metric, trControl=control))
# -> 221.36

predictions.nnet<-predict(fit.nnet,ohe.testdf)
caret::confusionMatrix(predictions.nnet, ohe.testdf$ARR_DEL15)
predictions.nnet1<-predict(fit.nnet1,ohe.testdf)
caret::confusionMatrix(predictions.nnet1, ohe.testdf$ARR_DEL15)
predictions.nnet.probs<-predict(fit.nnet,ohe.testdf, type='prob')

save(fit.nnet, file = "models/fit.nnet_data_2017_resampled_balancedacc.RData")

set.seed(7)
system.time(fit.LogitBoost <- caret::train(ARR_DEL15~., data=traindf, method="LogitBoost", 
                                           metric=metric, trControl=control))
# -> The final value used for the model was nIter = 21
# -> fit.logitboost: 71.64 
set.seed(7)
system.time(fit.LogitBoost1 <- caret::train(ARR_DEL15~., data=traindf, method="LogitBoost", 
                                            tuneGrid=tunegridlogitboost, metric=metric, trControl=control))
# -> The final value used for the model was nIter = 16
# -> fit.logitboost: 89.26 

tunegridlogitboost = expand.grid(nIter=seq(12,31,1))
set.seed(7)
system.time(fit.LogitBoost1 <- caret::train(ARR_DEL15~., data=traindf, method="LogitBoost", 
                                            tuneGrid=tunegridlogitboost, metric=metric, trControl=control))
# -> The final value used for the model was nIter = 15
# -> fit.logitboost: 20.08 

predictions.logitboost<-predict(fit.LogitBoost,testdf)
caret::confusionMatrix(predictions.logitboost, testdf$ARR_DEL15)
predictions.logitboost1<-predict(fit.LogitBoost1,testdf)
caret::confusionMatrix(predictions.logitboost1, testdf$ARR_DEL15)

predictions.logitboost.probs<-predict(fit.LogitBoost,testdf, type='prob')$no_delay

save(fit.LogitBoost, file = "models/fit.logitboost_data_2017_resampled_balancedacc.RData")
save(fit.LogitBoost1, file = "models/fit.logitboost1_data_2017_resampled_balancedacc.RData")

# Random Forest **********************************************************************************************
set.seed(7)
system.time(fit.rf<- caret::train(ARR_DEL15~., data=traindf, method="rf", 
                                  metric=metric, trControl=control))
# -> The final values used for the model were nrounds = 250, max_depth = 5, eta = 0.4, gamma = 0, colsample_bytree= 0.6, min_child_weight = 1 and subsample = 0.5.
# -> fit.logfit.rfitboost: 17110.96 

save(fit.rf, file = "models/fit.rf_data_2017_10000_balancedacc.RData")


# 5.0 Compare algorithms =============================================================
# collect resampling statistics of ALL trained models
results <- resamples(list( 
  CART    = fit.cart1,
  LR      = fit.logit,
  LR.reg  = fit.logitreg1,
  C50     = fit.C5.01,
  XGBoost = fit.xgb4,
  GBM     = fit.gbm))

# Summarize the fitted models
summary(results)
# Plot and rank the fitted models
dotplot(results)
dotplot(results, metric="Accuracy")

dotplot(results, metric=metric, main='Cross-Validated Balanced Accuracy')


# 6.0 Stacking Algorithms ===============================================================================
# -> AKA Model Ensembling
# -> Combine different classifiers using model stacking
# -> In other words, combine the predictions of multiple caret models using the caretEnsemble package.
# -> reference: https://cran.r-project.org/web/packages/caretEnsemble/vignettes/caretEnsemble-intro.html
# -> # -> https://www.analyticsvidhya.com/blog/2017/02/introduction-to-ensembling-along-with-implementation-in-r/
# Before stacking, we check correlations between predictions made by separate models, 
# -> If correlation is (< 0.75), stacking is more likely to be effective.
modelCor(results)

# 6.1 Stacking on 100k instances ========================================================================
# Specify the type of resampling, in this case, repeated 10-fold cross validation
trainControl <- trainControl(method="repeatedcv", 
                             number=4, 
                             repeats=2,
                             savePredictions=TRUE, 
                             verboseIter = TRUE,
                             returnData = FALSE,
                             returnResamp = "all",                       # save losses across all models
                             classProbs = TRUE,                          # set to TRUE for AUC to be computed
                             summaryFunction=multiClassSummary,
                             allowParallel = TRUE)

# Predicting the out of fold prediction probabilities for training data
ohe.traindf$OOF_pred_gbm_300<-fit.gbm.300k$pred$no_delay[order(fit.gbm.300k$pred$no_delay)]
ohe.traindf$OOF_pred_xgb_300<-fit.xgb.300k$pred$no_delay[order(fit.xgb.300k$pred$no_delay)]

# Predicting probabilities for the test data
ohe.testdf$OOF_pred_gbm_300 <- predict(fit.gbm.300k,ohe.testdf, type='prob')$no_delay
ohe.testdf$OOF_pred_xgb_300 <- predict(fit.xgb.300k,ohe.testdf, type='prob')$no_delay

# Predictors for top layer models 
predictors_top_300<-c('OOF_pred_xgb_300', 'OOF_pred_gbm_300') 

# Logistic Regression (Regularized) as top layer model 
set.seed(7)
fit.stackreglogit<- caret::train(ohe.traindf[,predictors_top_300],ohe.traindf$ARR_DEL15,
                                 method='regLogistic',trControl=trainControl, tuneLength=5)

# Get test-set scores
ohe.testdf$reglogit_stacked<-predict(fit.stackreglogit, ohe.testdf[,predictors_top_300])
caret::confusionMatrix(ohe.testdf$reglogit_stacked, ohe.testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
stackreglogit.prob<-predict(fit.stackreglogit, ohe.testdf[,predictors_top_300], type='prob')$no_delay
roc(ohe.testdf$ARR_DEL15, stackreglogit.prob)

# Save Models
save(fit.stackreglogit, file = "models/fit.stackreglogit.300k_data_2017_resampled_balancedacc.RData")

# 6.2 Stacking on 10k instances ========================================================================

# Predicting the out of fold prediction probabilities for training data
ohe.traindf$OOF_pred_gbm<-fit.gbm1$pred$no_delay[order(fit.gbm1$pred$no_delay)]
ohe.traindf$OOF_pred_xgb<-fit.xgb4$pred$no_delay[order(fit.xgb4$pred$no_delay)]
ohe.traindf$OOF_pred_reglogit<-fit.logitreg2$pred$no_delay[order(fit.logitreg2$pred$no_delay)]

# Predicting probabilities for the test data
ohe.testdf$OOF_pred_gbm <- predict(fit.gbm1,ohe.testdf, type='prob')$no_delay
ohe.testdf$OOF_pred_xgb <- predict(fit.xgb4,ohe.testdf, type='prob')$no_delay
ohe.testdf$OOF_pred_reglogit <- predict(fit.logitreg2,ohe.testdf, type='prob')$no_delay

# Predictors for top layer models 
predictors_top<-c('OOF_pred_xgb', 'OOF_pred_gbm') 


# Logistic Regression as top layer model 
set.seed(7)
fit.stacklogit<- caret::train(ohe.traindf[,predictors_top],ohe.traindf$ARR_DEL15,method='glm',trControl=trainControl)
# CART as top layer model 
set.seed(7)
fit.stackcart<- caret::train(ohe.traindf[,predictors_top],ohe.traindf$ARR_DEL15,method='rpart',trControl=trainControl, tuneLength=10)
# GBM as top layer model 
set.seed(7)
fit.stackgbm<- caret::train(ohe.traindf[,predictors_top],ohe.traindf$ARR_DEL15,method='gbm',trControl=trainControl, tuneLength=5)
# Logistic Regression (Regularized) as top layer model 
set.seed(7)
fit.stackreglogit<- caret::train(ohe.traindf[,predictors_top],ohe.traindf$ARR_DEL15,method='regLogistic',trControl=trainControl, tuneLength=5)

# Get test-set scores
ohe.testdf$glm_stacked<-predict(fit.stacklogit, ohe.testdf[,predictors_top])
caret::confusionMatrix(ohe.testdf$glm_stacked, ohe.testdf$ARR_DEL15)
ohe.testdf$cart_stacked<-predict(fit.stackcart, ohe.testdf[,predictors_top])
caret::confusionMatrix(ohe.testdf$cart_stacked, ohe.testdf$ARR_DEL15)
ohe.testdf$gbm_stacked<-predict(fit.stackgbm, ohe.testdf[,predictors_top])
caret::confusionMatrix(ohe.testdf$gbm_stacked, ohe.testdf$ARR_DEL15)
ohe.testdf$reglogit_stacked<-predict(fit.stackreglogit, ohe.testdf[,predictors_top])
caret::confusionMatrix(ohe.testdf$reglogit_stacked, ohe.testdf$ARR_DEL15)

# Retrieve predictions in probabilities, for ROC plots
glm_stacked.prob<-predict(fit.stacklogit, ohe.testdf[,predictors_top], type='prob')$no_delay
stackreglogit.prob<-predict(fit.stackreglogit, ohe.testdf[,predictors_top], type='prob')$no_delay
gbm_stacked.prob<-predict(fit.stackgbm, ohe.testdf[,predictors_top], type='prob')$no_delay

# Save Models
save(fit.stacklogit, file = "models/fit.stacklogit_data_2017_resampled_balancedacc.RData")
save(fit.stackreglogit, file = "models/fit.stackreglogit_data_2017_resampled_balancedacc.RData")


# Distribution of predictions plot =============================================================
dframe = data.frame(chd=as.factor(ohe.testdf$ARR_DEL15), 
                    prediction=predictions.xgb1.probs)

ggplot(ohe.testdf, aes(x=predictions.xgb1.probs, fill=ARR_DEL15)) + 
  geom_histogram(position="identity", binwidth=0.05, alpha=0.5)

hist(predictions.xgb1.probs)
ggplot(dframe, aes(x=predictions.xgb1.probs$no_delay, fill=chd)) +
  geom_histogram(binwidth=0.05, alpha=.5, position="identity")

# 7.0 Variable Importance plot =====================================================================
plot(varImp(fit.xgb4), top =20)
plot(varImp(fit.gbm1), top =20)

# 8.0 ROC plot =====================================================================================
# Create a ROC plot comparing performance of all models
library(randomcoloR)
library(pROC)
library(ROCR)
colors <- randomColor(count = 10, hue = c("random"), luminosity = c("dark"))
roc1 <- roc(testdf$ARR_DEL15, predictions.cart1.probs, col=colors[1], percent=TRUE, asp = NA,
            plot=TRUE, print.auc=TRUE, grid=TRUE, main="ROC comparison", print.auc.x=103, print.auc.y=100)
roc2 <- roc(testdf$ARR_DEL15, predictions.logit.probs, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[2], print.auc=TRUE, print.auc.x=103, print.auc.y=90)
roc3 <- roc(ohe.testdf$ARR_DEL15, predictions.logitreg1.probs, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[3], print.auc=TRUE, print.auc.x=103, print.auc.y=80)
roc4 <- roc(ohe.testdf$ARR_DEL15, predictions.c501.probs, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[4], print.auc=TRUE, print.auc.x=103, print.auc.y=70)
roc5 <- roc(testdf$ARR_DEL15, predictions.gbm.probs, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[5], print.auc=TRUE, print.auc.x=103, print.auc.y=60)
roc6 <- roc(testdf$ARR_DEL15, predictions.xgb4.probs, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[6], print.auc=TRUE, print.auc.x=103, print.auc.y=50)
roc7 <- roc(ohe.testdf$ARR_DEL15, fit.stackreglogit, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[7], print.auc=TRUE, print.auc.x=103, print.auc.y=40)
roc8 <- roc(ohe.testdf$ARR_DEL15, fit.stacklogit, plot=TRUE, add=TRUE, 
            percent=roc1$percent, col=colors[8], print.auc=TRUE, print.auc.x=103, print.auc.y=30)
legend("bottomright", legend=c("cart", "logistic regression", "regularized logistic reg",
                               "C5.0", "GBM", "XGBoost4", "Stack (logistic)", "Stack (reglogistic)" ), col=c(colors[1:7]), lwd=2)
# Use model ==============================================================================
load("models/fit.xgb_data_2017_10000.test.RData")
# flightData <- data.frame(MONTH = 4,
#                          DAY_OF_MONTH = 7,
#                          DAY_OF_WEEK = 7,
#                          CARRIER = "AA",
#                          ORIGIN_AIRPORT_ID = 12478, 
#                          DEST_AIRPORT_ID = 10397, 
#                          CRS_DEP_TIME = 0800,
#                          CRS_ARR_TIME = 0955,
#                          CRS_ELAPSED_TIME = 115, # Remove?
#                          DISTANCE = 746, # https://www.distance.to/Atlanta/New-York
#                          ORIGIN_AIRPORT_LAT = lookupLatitude(12478),
#                          ORIGIN_AIRPORT_LONG = lookupLongitude(12478),
#                          DEST_AIRPORT_LAT = lookupLatitude(10397),
#                          DEST_AIRPORT_LONG = lookupLongitude(10397))
#flightData2 <- data_2017_1000[1,]
predictions <- predictDelays(model = fit.xgb,
                             month = 4,
                             day_of_month = 7,
                             day_of_week = "Saturday",
                             carrier = "American",
                             origin_airport_id = 12478, # 12478 is New York
                             dest_airport_id = 10397, # 10397 is Atlanta
                             departure_time = 800,
                             arrival_time = 955,
                             flight_duration = 115, # Remove?
                             distance = 746 # https://www.distance.to/Atlanta/New-York
)
displayDelayProbabilities(predictions)
