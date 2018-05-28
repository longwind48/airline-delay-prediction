predictDelays <- function(model,
                          month,
                          day_of_month,
                          day_of_week,
                          carrier,
                          origin_airport_id,
                          dest_airport_id,
                          departure_time,
                          arrival_time,
                          flight_duration,
                          distance) {
  # Reference for portions of the code: https://jessesw.com/Air-Delays/
  # Create a dictionary for our Airlines
  carrier_dict <- list('Endeavor'=1,
                       'American'=2,
                       'Alaska'=3,
                       'JetBlue'=4,
                       'Delta'=5,
                       'ExpressJet'=6,
                       'Frontier'=7,
                       'AirTran'=8,
                       'Hawaiian'=9,
                       'Envoy'=10,
                       'SkyWest'=11,
                       'United'=12,
                       'US Airways'=13,
                       'Virgin'=14,
                       'Southwest'=15,
                       'Mesa'=16)
  carrier_num <- carrier_dict$carrier
  
  # Another dictionary for day of the week
  day_of_week_dict <- list('Monday'=1,
                           'Tuesday'=2,
                           'Wednesday'=3,
                           'Thursday'=4,
                           'Friday'=5,
                           'Saturday'=6,
                           'Sunday'=7)
  day_of_week_num <- day_of_week_dict$day_of_week
  
  # raw.flightData <- data.frame(MONTH               = month,
  #                              DAY_OF_MONTH        = day_of_month,
  #                              DAY_OF_WEEK         = day_of_week_num,
  #                              CARRIER             = carrier_num,
  #                              ORIGIN_AIRPORT_ID   = origin_airport_id,
  #                              DEST_AIRPORT_ID     = dest_airport_id,
  #                              CRS_DEP_TIME        = departure_time,
  #                              CRS_ARR_TIME        = arrival_time,
  #                              CRS_ELAPSED_TIME    = flight_duration, # Remove?
  #                              DISTANCE            = distance)
  # raw.flightData <- data.frame(DELAY_GROUPS        = NA,
  #                              MONTH               = 4,
  #                              DAY_OF_MONTH        = 7,
  #                              DAY_OF_WEEK         = 7,
  #                              CARRIER             = "AA",
  #                              ORIGIN_AIRPORT_ID   = 12478,
  #                              DEST_AIRPORT_ID     = 10397,
  #                              CRS_DEP_TIME        = 800,
  #                              CRS_ARR_TIME        = 955,
  #                              CRS_ELAPSED_TIME    = 115, # Remove?
  #                              DISTANCE            = 746,
  #                              ORIGIN_AIRPORT_LAT  = lookupLatitude(12478),
  #                              ORIGIN_AIRPORT_LONG = lookupLongitude(12478),
  #                              DEST_AIRPORT_LAT    = lookupLatitude(10397),
  #                              DEST_AIRPORT_LONG   = lookupLongitude(10397))
  # flightData <- engineerFeatures(raw.flightData, ohe = TRUE)
  predictions <- predict(model, newdata = ohe.testdf, type='prob')
  return(predictions[1,])
}