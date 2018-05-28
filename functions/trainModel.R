trainModel <- function(data) {
  # SETUP **********************************************************************************
  stats <- function (data, lev = NULL, model = NULL)  {
    c(postResample(data[, "pred"], data[, "obs"]),
      Sens = sensitivity(data[, "pred"], data[, "obs"]),
      Spec = specificity(data[, "pred"], data[, "obs"]))
  }
  
  control <- trainControl(method="cv", number=10, summaryFunction = stats, classProbs = TRUE)
  # -> The function trainControl can be used to specifiy the type of resampling,
  #    in this case, 10-fold cross validation.
  
  metric <- ""
  
  # columnsToExclude <- c(   "CARRIER_DELAY",
  #                          "WEATHER_DELAY",
  #                          "NAS_DELAY",
  #                          "SECURITY_DELAY",
  #                          "LATE_AIRCRAFT_DELAY")
  
  # LOGIT **********************************************************************************
  set.seed(7)
  
  fit.logit <- train(DELAY_GROUPS ~ .,
                     data=data,
                     method="glm",
                     family="multinomial", 
                     metric=metric,
                     trControl=control)
  
  # ?????? **********************************************************************************
  set.seed(7)
  # Try a second model here
  
  # ?????? **********************************************************************************
  set.seed(7)
  # Try a third model here
  
  # ?????? **********************************************************************************
  set.seed(7)
  # Try a fourth model here
  
  
  # Output Best Model ***********************************************************************
  best.model <- fit.logit # When logistic regression is the only model, it is the best one
  return(best.model)
}