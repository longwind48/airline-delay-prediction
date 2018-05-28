# Input
#  data: data frame with input flight data
#  ohe: binary option, TRUE or FALSE, to select whether or not to perform one-hot-encoding
# Output
#  data frame with only the features in the included.features collection,
#  either one-hot-encoded or not depending on whether ohe option is TRUE or FALSE
engineerFeatures <- function(data, ohe) {
  
  # data$SUN_MON <- ifelse((data$DAY_OF_WEEK==7 | data$DAY_OF_WEEK==1), 1, 0)
  # data$SUN_MON <- factor(data$SUN_MON)
  # 
  # source("functions/numFlightsIn2017FromAirport.R")
  # source("functions/lookupAirportData.R")
  # airportsByID <- levels(as.factor(data$ORIGIN_AIRPORT_ID))
  # airports <- lapply(airportsByID, lookupAirportData, RETURN = "AIRPORT")
  # airportSizesList <- lapply(airports, numFlightsIn2017FromAirport)
  # airportSizes.df <- data.frame(unlist(airportSizesList))
  # row.names(airportSizes.df) <- airports
  # airportSizes.df$unlist.airportSizesList. <- as.numeric(airportSizes.df$unlist.airportSizesList.)
  # threshold <- mean(na.omit(airportSizes.df$unlist.airportSizesList.))
  # airportSizes.df[is.na(airportSizes.df)] <- 0
  # airportSizes.df$AIRPORT_SIZE <- ifelse(airportSizes.df$unlist.airportSizesList. >= threshold, "Large", "Small")
  # airportSizes.df$AIRPORT_ID <- lapply(airports, lookupAirportDataIATA, RETURN = "AIRPORT_ID")
  # airportSizes.df$AIRPORT_ID <- as.numeric(airportSizes.df$AIRPORT_ID)
  # airportSize <- function(airport_id) {
  #   airportSizeForAIRPORT_ID <- airportSizes.df[airportSizes.df$AIRPORT_ID == airport_id,]$AIRPORT_SIZE
  #   return(airportSizeForAIRPORT_ID)
  # }
  # 
  # ORIGIN_AIRPORTS_COL <- data$ORIGIN_AIRPORT_ID
  # AIRPORT_SIZE <- airportSize(ORIGIN_AIRPORTS_COL)
  # data <- cbind(data, AIRPORT_SIZE)
  # data$AIRPORT_SIZE <- apply(data$ORIGIN_AIRPORT_ID, 1, airportSize)
  
  # Feature Selection and Engineering
  included.features <- c("ARR_DEL15",
                         "MONTH",
                         "DAY_OF_MONTH",
                         "DAY_OF_WEEK",
                         "CARRIER",
                         "ORIGIN_AIRPORT_ID",
                         "DEST_AIRPORT_ID",
                         "DEP_TIME_BINS",
                         "ARR_TIME_BINS",
                         "DISTANCE",
                         "ORIGIN_AIRPORT_STATE_NAME",
                         "DEST_AIRPORT_STATE_NAME",
                         "CRS_DEP_TIME_MINS",
                         "CRS_ARR_TIME_MINS"
                         #"CRS_DEP_TIME_MINS_SQUARED",
                         #"CRS_ARR_TIME_MINS_SQUARED"
                         #"ORIGIN_AIRPORT_SIZE",
                         #"DEST_AIRPORT_SIZE"
                         )
  #included.features <- c("ARR_DEL15")
  dataset <- data.frame(data)
  data.subset <- dataset[included.features]
  
  # One-Hot-Encode categorical features
  # -> we use OHE to perform “binarization??? of the categories and include them as a feature to train the model.
  # -> OHE transforms categorical features to a format that works better with classification and regression algorithms.
  # -> However, algorithms like randomF handle categorical features natively, so OHE is not necessary.
  
  if(ohe==TRUE) {
    # -> Before we OHE, we must convert our response variable to numerical, 
    #    because the following code transforms all factor type (categorical) features into OHE format.
    #    We don't want to OHE our reponse variable, we want it to stay as a factor type for modelling purposes.
    data.subset$ARR_DEL15 <- as.numeric(data.subset$ARR_DEL15)
    
    # One-Hot-Encode all factor type features, put all encoded features into new dataset.ohe
    dmy <- dummyVars(" ~ .", data = data.subset)
    data.subset.ohe <- data.frame(predict(dmy, newdata = data.subset))
    
    # Change response variable back to factor type
    data.subset.ohe$ARR_DEL15 <- factor(data.subset.ohe$ARR_DEL15)
  
    # Make valid names for response variable's classes since some models require valid names to work.
    levels(data.subset.ohe$ARR_DEL15) <- make.names(c("no_delay",
                                                         "delay"))
    return(data.subset.ohe)
  } else {
    levels(data.subset$ARR_DEL15) <- make.names(c("no_delay",
                                                      "delay"))
    return(data.subset)
  }
}
