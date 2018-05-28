# Dataset Description:
# -> This data contains airline data from the US Bureau of Transportation
# -> We intend to collate all 12 months of data and attempt to predict airline delays
#    using multiclass classifcation.
# -> Some information about features:
#    OriginAirportID: Identification number assigned by US DOT to identify a unique airport. 
#    DepTime: Actual Departure Time (local time: hhmm)
#    ArrDelay: (how early/late the plane was at its final destination in minutes
#    CRSDep: Scheduled Departure Time (local time: hhmm)
#    CRSElapsedTime (the scheduled difference between departure and arrival)
#    FLDATE: contains date of flight (for time-series analysis)
#    CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY: are reasons for delay (in mins) 

# Import csv file
# dataset <- read.csv("data/U.S.DOT.FlightDelayDataWithAppendedAirportCoordinates_2018_03_30.csv",
#                     header = TRUE,
#                     stringsAsFactors = FALSE)

# Read 2017 Flight Data
data_2017_01 <- read.csv("data/Flight_Data_2017_01.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_02 <- read.csv("data/Flight_Data_2017_02.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_03 <- read.csv("data/Flight_Data_2017_03.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_04 <- read.csv("data/Flight_Data_2017_04.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_05 <- read.csv("data/Flight_Data_2017_05.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_06 <- read.csv("data/Flight_Data_2017_06.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_07 <- read.csv("data/Flight_Data_2017_07.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_08 <- read.csv("data/Flight_Data_2017_08.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_09 <- read.csv("data/Flight_Data_2017_09.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_10 <- read.csv("data/Flight_Data_2017_10.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_11 <- read.csv("data/Flight_Data_2017_11.csv", header = TRUE, stringsAsFactors = TRUE)
data_2017_12 <- read.csv("data/Flight_Data_2017_12.csv", header = TRUE, stringsAsFactors = TRUE)

# Save monthly data to RData file
save.image("data/Flight_Data_2017_Monthly.RData")

# Combine Months into a Single Data Set
data_2017 <- rbind(data_2017_01,
                   data_2017_02,
                   data_2017_03,
                   data_2017_04,
                   data_2017_05,
                   data_2017_06,
                   data_2017_07,
                   data_2017_08,
                   data_2017_09,
                   data_2017_10,
                   data_2017_11,
                   data_2017_12)

# Save full year data to RData file
rm(data_2017_01)
rm(data_2017_02)
rm(data_2017_03)
rm(data_2017_04)
rm(data_2017_05)
rm(data_2017_06)
rm(data_2017_07)
rm(data_2017_08)
rm(data_2017_09)
rm(data_2017_10)
rm(data_2017_11)
rm(data_2017_12)
save.image("data/Flight_Data_2017.RData")

# Create smaller datasets for testing
completeIndex <- seq(from=1, to=length(data_2017[,1]), by=1)

set.seed(1)
randomIndex <- sample(completeIndex,
                      size = 1000,
                      replace = FALSE)
data_2017_1000 <- data_2017[randomIndex,]

set.seed(1)
randomIndex <- sample(completeIndex,
                      size = 10000,
                      replace = FALSE)
data_2017_10000 <- data_2017[randomIndex,]

set.seed(1)
randomIndex <- sample(completeIndex,
                      size = 100000,
                      replace = FALSE)
data_2017_100000 <- data_2017[randomIndex,]

set.seed(1)
randomIndex <- sample(completeIndex,
                      size = 500000,
                      replace = FALSE)
data_2017_500000 <- data_2017[randomIndex,]


# Save smaller subsets of data for testing
rm(data_2017)
rm(randomIndex)
rm(completeIndex)
save.image("data/Flight_Data_2017_Sampled.RData")

# Remove remaining variables
rm(data_2017_1000)
rm(data_2017_10000)
rm(data_2017_100000)
rm(data_2017_500000)