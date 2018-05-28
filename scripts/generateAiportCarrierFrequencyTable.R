source("scripts/loadLibraries.R")
load("data/Flight_Data_2017.RData")
load("data/Flight_Data_2017_Sampled.RData")
source("scripts/sourceFunctions.R")
data <- data_2017
airportsByID <- levels(as.factor(data$ORIGIN_AIRPORT_ID))
airports <- lapply(airportsByID, lookupAirportData, RETURN = "AIRPORT")
carriers <- levels(as.factor(data$CARRIER))

source("functions/flightsOriginatingFromAirport.R")
dataForEachAirport <- lapply(airports, flightsOriginatingFromAirport, data=data)
numOfFlightsByCarrier <- count(data, CARRIER)
#numOfFlightsByCarrierATL <- countCarrier(data, "ATL")
countCarrier <- function(data) {
  df <- count(data, CARRIER, sort=TRUE)
  #df <- cbind(df, AIRPORT=airport)
  return(df)
}

numOfFlightsByCarrierForEachAirport <- lapply(dataForEachAirport, countCarrier)
names(numOfFlightsByCarrierForEachAirport) <- airports

# for(i in 1:length(airports)) {
#   cat(paste("Airport",i,airports[i],"\n"))
#   numOfFlightsByCarrierForAirport <- countCarrier(dataForEachAirport[[i]])
#   cat(paste(numOfFlightsByCarrierForAirport$n,"\n"))
# }

#save(numOfFlightsByCarrierForEachAirport, file="data/numOfFlightsByCarrierForEachAirport.RData")
load("data/numOfFlightsByCarrierForEachAirport.RData")
numOfFlightsByCarrierForEachAirport$ATL
numOfFlightsByCarrierForEachAirport["ATL"]
