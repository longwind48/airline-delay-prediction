resampleCustom <- function(data, numberOfSamples) {
  subsetTrue  <- data[data$ARR_DEL15 == "delay",]
  subsetFalse <- data[data$ARR_DEL15 != "delay",]
  
  rownames(subsetTrue) <- seq(length=nrow(subsetTrue))
  rownames(subsetFalse) <- seq(length=nrow(subsetFalse))
  
  numTrue  <- length(subsetTrue$ARR_DEL15)
  numFalse <- length(subsetFalse$ARR_DEL15)
  
  indexTrue  <- seq(from=1, to=numTrue)
  indexFalse <- seq(from=1, to=numFalse)
  
  if(numberOfSamples/2 > numTrue || numberOfSamples/2 > numFalse) {
    cat("Error: numberOfSamples too large for data in resampleCustom function\n")
    return(NULL)
  }
  
  indexTrueSelected  <- sample(indexTrue, numberOfSamples/2, replace = FALSE)
  indexFalseSelected <- sample(indexFalse, numberOfSamples/2, replace = FALSE)
  
  subsetTrue  <- subsetTrue[(indexTrueSelected),]
  subsetFalse <- subsetFalse[(indexFalseSelected),]
  
  resampledData <- rbind(subsetTrue, subsetFalse)
  return(resampledData)
}

# data <- ohe.traindf
# numberOfSamples <- 20000
# table(data$ARR_DEL15)
# prop.table(table(data$ARR_DEL15))
# resampled.data <- resampleCustom(data, numberOfSamples)
# table(resampled.data$ARR_DEL15)
# prop.table(table(resampled.data$ARR_DEL15))

