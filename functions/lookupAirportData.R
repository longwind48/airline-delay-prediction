# Input:
#   AIRPORT_ID: the five digit number such as from either ORIGIN_AIRPORT_ID or DEST_AIRPORT_ID
#   RETURN: a string with the value to return e.g. "LATITUDE" or "LONGITUDE" or "DISPLAY_AIRPORT_CITY_NAME_FULL"
# Output: value in row corresponding to AIRPORT_ID in Airport_Data.csv and column specified by RETURN
# Example:
#  airport.name <- lookupAirportData(11057, RETURN = "DISPLAY_AIRPORT_NAME")

# Special functions for lat and long for faster performance and extra convenience
# Examples:
#  lat  <- lookupLatitude(11057)
#  long <- lookupLongitude(11057)

# Data for Functions =====================================================================
airportData <- read.csv("data/Airport_Data.csv", header = TRUE, stringsAsFactors = FALSE)
AIRPORT_ID_LIST <- airportData$AIRPORT_ID
AIRPORT_LIST <- airportData$AIRPORT
LATITIUDE_LIST <- airportData$LATITUDE
LONGITUDE_LIST <- airportData$LONGITUDE

# Function Definitions ===================================================================
lookupAirportData <- function(AIRPORT_ID, RETURN) {
  row.index <- match(AIRPORT_ID,AIRPORT_ID_LIST)
  column.of.interest <- airportData[,RETURN]
  return(column.of.interest[row.index])
}

lookupAirportDataIATA <- function(AIRPORT, RETURN) {
  row.index <- match(AIRPORT,AIRPORT_LIST)
  column.of.interest <- airportData[,RETURN]
  return(column.of.interest[row.index])
}

lookupLatitude <- function(AIRPORT_ID) {
  row.index <- match(AIRPORT_ID,AIRPORT_ID_LIST)
  return(LATITIUDE_LIST[row.index])
}

lookupLongitude <- function(AIRPORT_ID) {
  row.index <- match(AIRPORT_ID,AIRPORT_ID_LIST)
  return(LONGITUDE_LIST[row.index])
}

# Tests ==================================================================================
test.lat  <- lookupAirportData(11057, RETURN = "LATITUDE")
test.long <- lookupAirportData(11057, RETURN = "LONGITUDE")
test.DISPLAY_AIRPORT_NAME <- lookupAirportData(11057, RETURN = "DISPLAY_AIRPORT_NAME")
test.DISPLAY_AIRPORT_CITY_NAME_FULL <- lookupAirportData(11057, RETURN = "DISPLAY_AIRPORT_CITY_NAME_FULL")
test.AIRPORT_COUNTRY_NAME <- lookupAirportData(11057, RETURN = "AIRPORT_COUNTRY_NAME")
permissible.error <- 0.0000001
if( (abs(test.lat - 35.21916667) < permissible.error) &&
    (abs(test.long - (-80.9358333)) < permissible.error) &&
    (test.DISPLAY_AIRPORT_NAME == "Douglas Municipal") &&
    (test.DISPLAY_AIRPORT_CITY_NAME_FULL == "Charlotte, NC") &&
    (test.AIRPORT_COUNTRY_NAME == "United States")) {
  cat("lookupAirportData function test passed\n")
} else {
  cat("lookupAirportData function test failed\n")
}

test.lat <- lookupLatitude(11058)
if(abs(test.lat - 39.26194444) < permissible.error) {
  cat("lookupLatitude function test passed\n")
} else {
  cat("lookupLatitude function test failed\n")
}

test.long <- lookupLongitude(11058)
if(abs(test.long - (-85.89638889)) < permissible.error) {
  cat("lookupLongitude function test passed\n")
} else {
  cat("lookupLongitude function test failed\n")
}
