# Load data
#load("data/Flight_Data_2017.RData")
load("data/Flight_Data_2017_Sampled.RData")
#load("data/Flight_Data_2017_Monthly.RData")
load("IgnoredFiles/data_2017_appended.RData")

# Load libraries and functions ===========================================================
source("scripts/loadLibraries.R")
source("functions/trainModel.R")
source("functions/lookupAirportData.R")
source("functions/preprocess.R")
source("functions/clean.R")
source("functions/engineerFeatures.R")
source("functions/splitIntoTrainAndTest.R")
source("functions/analyzeCausesOfDelay.R")
source("functions/UnivariateAnalysis.R")
source("functions/multivariateAnalysis.R")
source("functions/predictDelays.R")
source("functions/max_num_flights.R")
source("functions/displayDelayProbabilities.R")
source("functions/appendAirportData.R")
source("functions/resample.R")

# Preprocess full dataset and add additional columns
# preprocessed.data <- preprocess(data_2017)
# data <- preprocessed.data
# data <- appendAirportData(data, "AIRPORT", factor = TRUE)
# data <- appendAirportData(data, "AIRPORT_STATE_NAME", factor = TRUE)
# data <- appendAirportData(data, "AIRPORT_COUNTRY_NAME", factor = TRUE)
# data <- appendAirportData(data, "DISPLAY_AIRPORT_NAME", factor = TRUE)
# data <- appendAirportData(data, "DISPLAY_CITY_MARKET_NAME_FULL", factor = TRUE)
# data_2017_appended <- data
# save(data_2017_appended, file = "IgnoredFiles/data_2017_appended.RData")

str(data_2017_appended)
Airports <- data_2017_appended$ORIGIN_AIRPORT
numFlightsIn2017FromAirportData <- summary(Airports)
save(numFlightsIn2017FromAirportData,
     file = "data/numFlightsIn2017FromAirportData.RData")
plot(sort(summary(factor(Airports))),
     ylab = "Number of Flights",
     xlab = "AIRPORT",
     main = "Number of Flights for Each Airport in 2017\nIn Increasing Order")
sort(summary(factor(Airports)))
lookupAirportDataIATA(AIRPORT = "ATL", RETURN = "DISPLAY_AIRPORT_NAME")
lookupAirportDataIATA(AIRPORT = "ORD", RETURN = "DISPLAY_AIRPORT_NAME")
lookupAirportDataIATA(AIRPORT = "DEN", RETURN = "DISPLAY_AIRPORT_NAME")
lookupAirportDataIATA(AIRPORT = "LAX", RETURN = "DISPLAY_AIRPORT_NAME")
lookupAirportDataIATA(AIRPORT = "DFW", RETURN = "DISPLAY_AIRPORT_NAME")

Airports2 <- data_2017_10000$ORIGIN_AIRPORT_ID
numFlightsFromAirportData_10000 <- summary(factor(Airports2))
numFlightsFromAirportData_10000
plot(sort(numFlightsFromAirportData_10000),
     xlab = "AIRPORT_ID",
     main = "Number of Flights for Each Airport in 10k Data\nIn Increasing Order")
str(numFlightsFromAirportData_10000)


