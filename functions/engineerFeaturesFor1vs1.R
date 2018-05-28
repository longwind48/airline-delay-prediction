# Input
#  data: data frame with input flight data
#  ohe: binary option, TRUE or FALSE, to select whether or not to perform one-hot-encoding
# Output
#  data frame with only the features in the included.features collection,
#  either one-hot-encoded or not depending on whether ohe option is TRUE or FALSE
engineerFeaturesFor1vs1 <- function(data) {
  # Feature Selection and Engineering
    
  included.features <- c("DELAY_GROUPS",
                         "MONTH",
                         "DAY_OF_MONTH",
                         "DAY_OF_WEEK",
                         "CARRIER",
                         "ORIGIN_AIRPORT_ID",
                         "DEST_AIRPORT_ID",
                         "CRS_DEP_TIME",
                         "CRS_ARR_TIME",
                         #"CRS_ELAPSED_TIME", # Remove?
                         "DISTANCE",
                         "ORIGIN_AIRPORT_LAT",
                         "ORIGIN_AIRPORT_LONG",
                         "DEST_AIRPORT_LAT",
                         "DEST_AIRPORT_LONG",
                         "ORIGIN_AIRPORT_STATE_NAME",
                         "DEST_AIRPORT_STATE_NAME"
                         #"ORIGIN_DISPLAY_CITY_MARKET_NAME_FULL",
                         )#"DEST_DISPLAY_CITY_MARKET_NAME_FULL")
  data.subset <- data[included.features]
  
  # One-Hot-Encode categorical features
  # -> we use OHE to perform “binarization? of the categories and include them as a feature to train the model.
  # -> OHE transforms categorical features to a format that works better with classification and regression algorithms.
  # -> However, algorithms like randomF handle categorical features natively, so OHE is not necessary.

  # One-Hot-Encode all factor type features, put all encoded features into new dataset.ohe
  data.subset$ORIGIN_AIRPORT_ID <- as.numeric(data.subset$ORIGIN_AIRPORT_ID)
  data.subset$DEST_AIRPORT_ID <- as.numeric(data.subset$DEST_AIRPORT_ID)
  dmy <- dummyVars(" ~ .", data = data.subset)
  data.ohe <- data.frame(predict(dmy, newdata = data.subset))
  data.subset$ORIGIN_AIRPORT_ID <- as.factor(data.subset$ORIGIN_AIRPORT_ID)
  data.subset$DEST_AIRPORT_ID <- as.factor(data.subset$DEST_AIRPORT_ID)
  
  d <- data.ohe
  index1 <- d$DELAY_GROUPS.no_delay > 0
  index2 <- d$DELAY_GROUPS.delay.1.to.15.mins > 0
  index3 <- d$DELAY_GROUPS.delay.16.to.30.mins > 0
  index4 <- d$DELAY_GROUPS.delay.30.to.45.mins > 0
  index5 <- d$DELAY_GROUPS.delay.46.to.60.mins > 0
  index6 <- d$DELAY_GROUPS.delay.60.to.120.mins > 0
  index7 <- d$DELAY_GROUPS.delay.121.mins.or.more > 0
  
  index1
  index2
  index3
  index4
  index5
  index6
  index7
  index8
  d1 <- data.subset[(index1 || index2),]
  
  # To be continued...
  
  return(list(index1, index2, index3, index4, index5, index6, index7))
}
