# Test values
origin <- "ATL"
dest <- "LAX"
month <- "Apr"
day_of_month <- 15
day_of_week <- "Sat"
dept_time <- 1650
arr_time <- 1851

# Data for and model for function
source("scripts/loadLibraries.R")
source("scripts/sourceFunctions.R")
#load("data/default.flights.raw.data.RData")
load("data/numOfFlightsByCarrierForEachAirport.RData")
#load("models/fit.cart1.7k.20180413.RData")
load("models/fit.xgb.300k_data_2017_resampled_balancedacc.RData")
load("data/Flight_Data_2017.RData")
set.seed(7)
default.flights.raw.data <- sample_n(data_2017, 300000)

carrierCodes <- c("AA","AS","B6","DL","EV","F9","HA","NK","OO","UA","VX","WN")

month_dict <- list('Jan'=1,
                   'Feb'=2,
                   'Mar'=3,
                   'Apr'=4,
                   'May'=5,
                   'Jun'=6,
                   'Jul'=7,
                   'Aug'=8,
                   'Sep'=9,
                   'Oct'=10,
                   'Nov'=11,
                   'Dec'=12)

day_of_week_dict <- list('Mon'=1,
                         'Tue'=2,
                         'Wed'=3,
                         'Thu'=4,
                         'Fri'=5,
                         'Sat'=6,
                         'Sun'=7,
                         'Unknown'=9)
carrier_dict <- list("AA"="American Airlines Inc.",
                     "AS"="Alaska Airlines Inc.",
                     "B6"="JetBlue Airlines",
                     "DL"="Delta Air Lines Inc.",
                     "EV"="ExpressJet Airlines Inc.",
                     "F9"="Frontier Airlines Inc.",
                     "HA"="Hawaiian Airlines Inc.",
                     "NK"="Spirit Air Lines",
                     "OO"="SkyWest Airlines Inc.",
                     "UA"="United Air Lines Inc.",
                     "VX"="Virgin America",
                     "WN"="Southwest Airlines Co.")

# Function Definition
compareCarrierDelays <- function(origin,
                                 dest,
                                 month,
                                 day_of_month,
                                 day_of_week,
                                 dept_time,
                                 arr_time
) {
  origin_id <- lookupAirportDataIATA(origin, RETURN="AIRPORT_ID")
  dest_id <- lookupAirportDataIATA(dest, RETURN="AIRPORT_ID")
  
  d.2017 <- data_2017
  d.origin <- d.2017[d.2017$ORIGIN_AIRPORT_ID==origin_id,]
  d.dest <- d.2017[d.2017$DEST_AIRPORT_ID==dest_id,]
  d.origin.dest <- d.origin[d.origin$DEST_AIRPORT_ID==dest_id,]
  d.origin.dest.delayed <- d.origin.dest[d.origin.dest$ARR_DEL15==1,]
  carriers.on.route <- data.frame(count(d.origin.dest,CARRIER))
  delays.on.route <- data.frame(count(d.origin.dest.delayed,CARRIER))
  
  numCarriersToCompare <- length(carriers.on.route$CARRIER)
  carriers <- carriers.on.route$CARRIER
  
  numFlightsOnRoute <- length(d.origin.dest$ARR_DEL15)
  numDelayedFlightsOnRoute <- length(d.origin.dest.delayed$ARR_DEL15)
  if(numFlightsOnRoute!=0) {
    percDelayedFlightsOnRoute <- numDelayedFlightsOnRoute/numFlightsOnRoute
  } else {
    percDelayedFlightsOnRoute <- NA
  }
  
  # -------------------------------------------------------------------------
  # Future work: Check for errors here e.g. no flights from origin to dest
  # -------------------------------------------------------------------------
  
  distance <- as.numeric(d.origin.dest[1,"DISTANCE"])
  month_num <- month_dict[[month]]
  day_of_week_num <- day_of_week_dict[[day_of_week]]

  d <- default.flights.raw.data[1:numCarriersToCompare,]
  d$MONTH             <- rep(month_num, numCarriersToCompare)
  d$DAY_OF_MONTH      <- rep(day_of_month, numCarriersToCompare)
  d$DAY_OF_WEEK       <- rep(day_of_week_num, numCarriersToCompare)
  d$CARRIER           <- carriers
  d$ORIGIN_AIRPORT_ID <- rep(lookupAirportDataIATA(origin, RETURN="AIRPORT_ID"), numCarriersToCompare)
  d$DEST_AIRPORT_ID   <- rep(lookupAirportDataIATA(dest, RETURN="AIRPORT_ID"), numCarriersToCompare)
  d$CRS_DEP_TIME      <- rep(dept_time, numCarriersToCompare)
  d$CRS_ARR_TIME      <- rep(arr_time, numCarriersToCompare)
  d$DISTANCE          <- rep(distance, numCarriersToCompare)

  # These next few lines are highly inefficient
  # Future work: add columns for one-hot encoding more efficiently to enhance performance
  d <- preprocess(rbind(d,default.flights.raw.data)) # So that ohe can occur (fails with only 1 factor level)
  d <- d[1:numCarriersToCompare,]
  d.clean <- clean(d)
  d.out <- engineerFeatures(d.clean, ohe=FALSE)
  d.out <- d.out[1:numCarriersToCompare,]
  d.out.ohe <- engineerFeatures(d.clean, ohe=TRUE)
  d.out.ohe <- d.out.ohe[1:numCarriersToCompare,]
  
  predictions <- predict(fit.xgb.300k, d.out.ohe, type='prob')

  goodColor <- "green"
  badColor <- "red"
  delayColors <- rep("gray", numCarriersToCompare)
  for(i in 1:numCarriersToCompare) {
    if(predictions$delay[i] > 0.5) {delayColors[i] <- badColor} else {delayColors[i] <- goodColor}
  }
  
  par(mfrow=c(1,2))
  par(mar=c(5,10,5,2))
  barplot(predictions$delay,
          horiz = TRUE,
          las = 1,
          main = paste(origin,"to",dest,"\n",day_of_week,month,day_of_month,"\n",dept_time,"to",arr_time),
          xlab = "Delay Prediction\nRed = Delay, Green = On-time",
          names.arg = carrier_dict[carriers],
          col = delayColors,
          cex.names = 1.0,
          xlim = c(0,1))
  par(mar=c(5,2,5,10))
  barplot(carriers.on.route$n,
          horiz = TRUE,
          las = 1,
          main = paste(origin,"to",dest,"\n2017"),
          xlab = "Number of Flights in 2017",
          col = rep("gray", numCarriersToCompare),
          cex.names = 1.0)
}

# Test cases
compareCarrierDelays(origin="MSP",
                     dest="SFO",
                     month="Jan",
                     day_of_month=8,
                     day_of_week="Wed",
                     dept_time=0600,
                     arr_time=0900)

compareCarrierDelays(origin="ATL",
                     dest="LAX",
                     month="Apr",
                     day_of_month=28,
                     day_of_week="Sat",
                     dept_time=1250,
                     arr_time=1451)
