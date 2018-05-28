resample <- function(data) {
  # SMOTE Synthetic Minority Over-sampling Technique
  resampled.data <- SMOTE(ARR_DEL15 ~ ., data, perc.over = 100, perc.under = 200)
  return(resampled.data)
}

# test.df <- data.frame(Col1=c(1,2,3,4,5,6,7,8,9,10),
#                       Col2=c(1,2,3,4,5,6,7,8,9,10),
#                       Response=c(1,1,0,0,0,0,0,0,0,0))
# test.resampled <- resample(test.df)
# test.resampled

# prop.table(table(traindf$ARR_DEL15))
# table(traindf$ARR_DEL15)
# library(DMwR)
# traindf.resampled <- resample(traindf)
# traindf.resampled <- SMOTE(ARR_DEL15 ~ ., traindf, perc.over = 100, perc.under=200)
# prop.table(table(traindf.resampled$ARR_DEL15))
# table(traindf.resampled$ARR_DEL15)