load("data/numFlightsIn2017FromAirportData.RData")
numFlightsIn2017FromAirport <- function(AirportCodeIATA) {
  return(numFlightsIn2017FromAirportData[AirportCodeIATA])
}

# Test function
# numFlightsIn2017FromAirport("MSP")
# numFlightsIn2017FromAirport("LAX")
