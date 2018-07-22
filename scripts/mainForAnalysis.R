# Master script to run helper scripts
# Authors: Traci Lim, Willian Skinner, Yi Luo

# Options ================================================================================
reloadDataFromCSV <- FALSE;

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
source("functions/resampleCustom.R")
source("functions/toMinutesAfterMidnight.R")
source("functions/numFlightsIn2017FromAirport.R")

# Import Data from CSV Files and save to RData files =====================================
if(reloadDataFromCSV) {
  source("scripts/importMonthlyDataFromCSVAndSaveAsRData.R")
}

# Import and preprocess data =============================================================

# Load data from files and select raw data set
#load("data/Flight_Data_2017_Monthly.RData")
#load("data/Flight_Data_2017.RData")
load("data/Flight_Data_2017_Sampled.RData")

raw.data <- data_2017_100000

# Preprocess data to set data types, 
preprocessed.data <- preprocess(raw.data)

# Deal with missing values
clean.data <- clean(preprocessed.data)

#add lats and longs, and break response into classes
preprocessed.data <- appendAirportData(preprocessed.data, "AIRPORT_STATE_NAME", factor = TRUE)
preprocessed.data <- appendAirportData(preprocessed.data, "DISPLAY_AIRPORT_NAME", factor = TRUE)
preprocessed.data <- appendAirportData(preprocessed.data, "DISPLAY_CITY_MARKET_NAME_FULL", factor = TRUE)
preprocessed.data <- appendAirportData(preprocessed.data, "AIRPORT", factor = TRUE)

# Select features and split dataset
# data <- engineerFeatures(clean.data, ohe=FALSE)
# data.list <- splitIntoTrainAndTest(data)
# traindf <- data.list[["train"]]
# traindf <- resampleCustom(traindf, 10000)
# testdf <- data.list[["test"]]

# Select features, perform one-hot-encoding, and split dataset
# ohe.data <- engineerFeatures(clean.data, ohe=TRUE)
# ohe.data.list <- splitIntoTrainAndTest(ohe.data)
# ohe.traindf <- ohe.data.list[["train"]]
# ohe.traindf <- resampleCustom(ohe.traindf, 20000)
# ohe.testdf <- ohe.data.list[["test"]]

# Analyze data ===========================================================================
dataForAnalysisOfCausesOfDelay <- splitIntoTrainAndTest(clean.data)[["train"]]
# analyzeCausesOfDelay(dataForAnalysisOfCausesOfDelay)

# dataForAnalysis <- traindf
# univariateAnalysis(dataForAnalysis)
# multivariateAnalysis(dataForAnalysis, cat=TRUE)
# multivariateAnalysis(dataForAnalysis, cat=FALSE)

