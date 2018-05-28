# Preprocess Dataset
preprocess <- function(data) {
  dataset <- data
  dataset$X <- NULL
  dataset$DELAY_GROUPS <- cut(dataset$ARR_DELAY, 
                               breaks = c(-Inf, 1, 16, 31, 46, 61, 121, Inf),
                               labels = c("no_delay",
                                          "delay.1.to.15.mins",
                                          "delay.16.to.30.mins",
                                          "delay.31.to.45.mins",
                                          "delay.46.to.60.mins",
                                          "delay.61.to.120.mins",
                                          "delay.121.mins.or.more"), 
                               right = FALSE)
  # -> Any number < 0 is grouped as 'no delay' and numbers > 0 are grouped in 15 min intervals
  # -> DELAY_GROUPS has 7 classes.
  # -> This will be our reponse variable.
  
  # Convert FL_DATE feature from string type to date type
  dataset$FL_DATE <- as.Date(dataset$FL_DATE)#->luoyi:my PC only works without "%d/%m/%Y",otherwise will return a full column of NAs
  
  # Convert features to categorical type
  dataset$ARR_DEL15 <- factor(dataset$ARR_DEL15)
  dataset$CARRIER <- factor(dataset$CARRIER)
  dataset$ORIGIN_AIRPORT_ID <- factor(dataset$ORIGIN_AIRPORT_ID)
  dataset$DEST_AIRPORT_ID <- factor(dataset$DEST_AIRPORT_ID)
  dataset$MONTH <- factor(dataset$MONTH)
  dataset$DAY_OF_MONTH <- factor(dataset$DAY_OF_MONTH)
  dataset$DAY_OF_WEEK <- factor(dataset$DAY_OF_WEEK)
  
  CRS_DEP_TIME_MINS <- toMinutesAfterMidnight(dataset$CRS_DEP_TIME)
  CRS_ARR_TIME_MINS <- toMinutesAfterMidnight(dataset$CRS_ARR_TIME)
  CRS_DEP_TIME_MINS_SQUARED <- toMinutesAfterMidnightSquared(dataset$CRS_DEP_TIME)
  CRS_ARR_TIME_MINS_SQUARED <- toMinutesAfterMidnightSquared(dataset$CRS_ARR_TIME)
  dataset <- cbind(dataset,
                   CRS_DEP_TIME_MINS,
                   CRS_ARR_TIME_MINS,
                   CRS_DEP_TIME_MINS_SQUARED,
                   CRS_ARR_TIME_MINS_SQUARED)
  
  dataset$DEP_TIME_BINS <- cut(dataset$CRS_DEP_TIME,  breaks = c(1, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100,
                                                                 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100,
                                                                 2200, 2300, 2400), right=FALSE)
  levels(dataset$DEP_TIME_BINS) <- make.names(c("0000.to.0100", "0100.to.0159", "0200.to.0259", "0300.to.0359",
                                                "0400.to.0459", "0500.to.0559", "0600.to.0659", "0700.to.0759",
                                                "0800.to.0859", "0900.to.0959", "1000.to.1059", "1100.to.1159",
                                                "1200.to.1259", "1300.to.1359", "1400.to.1459", "1500.to.1559",
                                                "1600.to.1659", "1700.to.1759", "1800.to.1859", "1900.to.1959",
                                                "2000.to.2059", "2100.to.2159", "2200.to.2259", "2300.to.2359"))
  dataset$ARR_TIME_BINS <- cut(dataset$CRS_ARR_TIME,  breaks = c(1, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100,
                                                                 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100,
                                                                 2200, 2300, 2400), right=FALSE)
  levels(dataset$ARR_TIME_BINS) <- make.names(c("0000.to.0100", "0100.to.0159", "0200.to.0259", "0300.to.0359",
                                                "0400.to.0459", "0500.to.0559", "0600.to.0659", "0700.to.0759",
                                                "0800.to.0859", "0900.to.0959", "1000.to.1059", "1100.to.1159",
                                                "1200.to.1259", "1300.to.1359", "1400.to.1459", "1500.to.1559",
                                                "1600.to.1659", "1700.to.1759", "1800.to.1859", "1900.to.1959",
                                                "2000.to.2059", "2100.to.2159", "2200.to.2259", "2300.to.2359"))
  
  
  # Additional features to add
  ORIGIN_AIRPORT_LAT <- as.numeric(lookupLatitude(dataset$ORIGIN_AIRPORT_ID))
  ORIGIN_AIRPORT_LONG <- as.numeric(lookupLongitude(dataset$ORIGIN_AIRPORT_ID))
  DEST_AIRPORT_LAT <- as.numeric(lookupLatitude(dataset$DEST_AIRPORT_ID))
  DEST_AIRPORT_LONG <- as.numeric(lookupLongitude(dataset$DEST_AIRPORT_ID))
  
  ORIGIN_AIRPORT_SIZE <- as.numeric(numFlightsIn2017FromAirport(lookupAirportData(dataset$ORIGIN_AIRPORT_ID, RETURN="AIRPORT")))
  DEST_AIRPORT_SIZE   <- as.numeric(numFlightsIn2017FromAirport(lookupAirportData(dataset$DEST_AIRPORT_ID, RETURN="AIRPORT")))
  
  preprocessed.data <- cbind(dataset,
                             ORIGIN_AIRPORT_LAT,
                             ORIGIN_AIRPORT_LONG,
                             DEST_AIRPORT_LAT,
                             DEST_AIRPORT_LONG,
                             ORIGIN_AIRPORT_SIZE,
                             DEST_AIRPORT_SIZE)
  
  preprocessed.data <- appendAirportData(preprocessed.data, "AIRPORT_STATE_NAME", factor = TRUE)
  preprocessed.data <- appendAirportData(preprocessed.data, "DISPLAY_AIRPORT_NAME", factor = TRUE)
  preprocessed.data <- appendAirportData(preprocessed.data, "DISPLAY_CITY_MARKET_NAME_FULL", factor = TRUE)
  preprocessed.data <- appendAirportData(preprocessed.data, "AIRPORT", factor = TRUE)
  
  return(preprocessed.data)
}