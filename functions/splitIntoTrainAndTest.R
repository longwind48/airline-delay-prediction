# Input
#   data: a full data frame to split into training data and test data
# Output
#   dataListTrainTest: list of two data frames traindf and testdf respectively
# Example
#   myDataList <- splitIntoTrainAndTest(dataset)
#   traindf <- myDataList[["train"]]
#   testdf  <- myDataList[["test"]]

# splitIntoTrainAndTest <- function(data) {
#   fractionTrainingData <- 0.7
#   numberOfRows <- length(data[,1])
#   completeIndex <- seq(from=1, to=numberOfRows, by=1)
#   set.seed(7)
#   numberOfSamplesToTake <- fractionTrainingData*numberOfRows
#   train.index <- sample(completeIndex,numberOfSamplesToTake)
#   # select 70% of the data for the training dataset
#   traindf <- data[train.index,]
#   # use the remaining 30% of the data for creating testing dataset
#   testdf <- data[-train.index,]
#   dataListTrainTest <- list(train=traindf, test=testdf)
#   return(dataListTrainTest)
# }
splitIntoTrainAndTest <- function(dataset, fractionToTrain = 0.7) {
  # Shrink the dataset to train our models faster, 10%
  # cutoff = round(0.1*nrow(dataset))
  # dataset <- dataset[1:cutoff,]
  # Use the same index we used to split earlier
  set.seed(7)
  #test.index <- createDataPartition(dataset$DELAY_GROUPS, p=0.7, list=FALSE)
  test.index <- createDataPartition(dataset$ARR_DEL15, p=fractionToTrain, list=FALSE)
  # Select 30% of the data for testing by default
  testdf <- dataset[-test.index,]
  # Use the remaining 70% of data for creating training dataset
  traindf <- dataset[test.index,]
  dataListTrainTest <- list(train=traindf, test=testdf)
  return(dataListTrainTest)
}

# Testing function ===========================================================================
# test.df <- data.frame(Col1=c(1,2,3,4,5,6,7,8,9,10),
#                       Col2=c(10,20,30,40,50,60,70,80,90,100))
# test.list <- splitIntoTrainAndTest(test.df)
# test.traindf <- test.list[["train"]]
# test.testdf  <- test.list[["test"]]
# 
# expected.traindf <- data.frame(Col1=c(10,4,1,8,2,9,6),
#                                Col2=c(100,40,10,80,20,90,60))
# expected.testdf <- data.frame(Col1=c(3,5,7),
#                               Col2=c(30,50,70))
# traindf.passed <- TRUE
# compare.traindf <- (test.traindf == expected.traindf)
# if(exists("compare.traindf")==FALSE){
#   traindf.passed <- FALSE
# }
# for(i in 1:length(compare.traindf[,1])) {
#   for(j in 1:length(compare.traindf[1,])) {
#     if(compare.traindf[i,j] == FALSE) {
#       traindf.passed <- FALSE
#     }
#   }
# }
# 
# testdf.passed <- TRUE
# compare.testdf <- (test.testdf == expected.testdf)
# if(exists("compare.testdf")==FALSE){
#   testdf.passed <- FALSE
# }
# for(i in 1:length(compare.testdf[,1])) {
#   for(j in 1:length(compare.testdf[1,])) {
#     if(compare.testdf[i,j] == FALSE) {
#       testdf.passed <- FALSE
#     }
#   }
# }
# 
# if(traindf.passed && testdf.passed) {
#   cat("splitIntoTrainAndTest function test passed")
# } else {
#   cat("splitIntoTrainAndTest function test failed")
# }
