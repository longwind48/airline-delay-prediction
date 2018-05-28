source("functions/lookupAirportData.R")

flightsOriginatingFromAirport <- function(airport, data) {
  AIRPORT_ID <- lookupAirportDataIATA(airport, "AIRPORT_ID")
  flights.subset <- data[data$ORIGIN_AIRPORT_ID == AIRPORT_ID,]
  return(flights.subset)
}

flightsByCarrier <- function(carrier, data) {
  flights.subset <- data[data$CARRIER == carrier,]
  return(flights.subset)
}

flightsFromAirportByCarrier <- function(airport, carrier, data) {
  AIRPORT_ID <- lookupAirportDataIATA(airport, "AIRPORT_ID")
  index <- (data$ORIGIN_AIRPORT_ID == AIRPORT_ID) && (data$CARRIER == carrier)
  flights.subset <- data[index,]
}

# airport <- "MSP"
# flightsFromAirport <- flightsOriginatingFromAirport(airport)
# length(flightsFromAirport$CARRIER)
