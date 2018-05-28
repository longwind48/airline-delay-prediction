# Authors: Traci Lim, Willian Skinner, Yi Luo

# Dataset Description:
# -> This data contains airline data from the US Bureau of Transportation for the period of January 2017
# -> We intend to collate all 12 months of data and attempt to predict airline delays using multiclass classifcation.
# -> Some information about features:
#    OriginAirportID: Identification number assigned by US DOT to identify a unique airport. 
#    DepTime: Actual Departure Time (local time: hhmm)
#    ArrDelay: (how early/late the plane was at its final destination in minutes
#    CRSDep: Scheduled Departure Time (local time: hhmm)
#    CRSElapsedTime (the scheduled difference between departure and arrival)
#    FLDATE: contains date of flight (for time-series analysis)
#    CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY: are reasons for delay (in mins) 

# SOME NOTES: 
# -> "# ->" indicate personal comments/intuition
#    "#" indicate the main objective of code

# -> ***Changelog.v1*** Date: 19/03/2018 
# -> Added CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY features: 
#    Yi's suggestion made alot of sense, we can use this to gather more information about what causes delays.
#    Although there's alot of missing data in these features, it has at least 50k rows, which is enough for a sound analysis.
# -> Added FLTIME feature: we converted it to date format, can potential lead to simple time-series plots
# -> Added DELAY_GROUPS feature: as a response variable for multiclass classification (justification below)
# -> Added code for plotting latitude and longitude data
# -> Please use the data i uploaded, i used a vlookup to fill in the longitude and latitude from a new data source,
#    it's different from the one bill did. Apparently the latlong information is not accurate.
# -> Section 1 to 6 can be run smoothly.

# -> ***Changelog.v4*** Date: 03/04/2018 
# -> Changed section 5.0: Feature Engineering
# -> Changed section 1.0: added another data, Airport_Lookup.csv, for section 12.0 function implemention 
# -> Added section 8: Evaluate Algorithms: 5 models added 
# -> Added section 9: Compare Algorithms
# -> Added section 12: Function Implementation: nearly done with a working R function that implements predictions.
# -> Tasks left: Download full 2017 dataset, re-train models on full dataset, 
#    Change metric to area under ROC curve and re-train models, Change metric to area under ROC curve, 
#    because after selecting the model that gave the best accuracy gave me spurious predictions. 

# 1.0 Importing Data ===========================================================================================
setwd("C:/Users/longwind48/Google Drive/Programming/Projects/Airline Delay")
setwd("C:/Users/Bill/Google Drive/MA429_Shared/3 Final_Project")
setwd("C:/Users/longwind48/Google Drive/Programming/Projects/Airline Delay Gitlab/LSEMA429")
setwd("C:/Users/luoyi/Desktop/LSEMA429")
# Import csv file
#dataset <- read.csv("data/Airline_Delay_Edited_19032018.csv", header = TRUE, stringsAsFactors = FALSE)
#load("data/Flight_Data_2017.RData")
load("data/Flight_Data_2017_Sampled.RData")
dataset <- data_2017_100000
dataset$X <- NULL

#airport_lookupDF <- read.csv("data/Airport_Lookup.csv", header = TRUE, stringsAsFactors = FALSE)
#airports.raw <- read.csv("data/airports.csv", header=TRUE, stringsAsFactors = FALSE)
#airports.raw$X <- NULL
#airports <- airports.raw

# 1.1 Load libraries
load.libraries <- c('dplyr', 'Hmisc', 'ggplot2', 'ggmap', 'igraph', 'ggplot2', 'lattice', 'OpenStreetMap',
                    'GoodmanKruskal', 'caret', 'ROCR', 'corrplot', 'ggthemes', 'tictoc', 'MASS', 'caTools',
                    'xgboost', 'Matrix', 'MLmetrics', 'doParallel', 'bst', 'RSNNS', 'caret', 'caretEnsemble',
                    'ROCR',"timeDate","gridExtra")
sapply(load.libraries, require, character = TRUE)

# 1.1.5 install missing packages function
ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
}
ipak(load.libraries)


# 1.2 Create multiclass categorical response variable from numerical variable ARR_DELAY
# Check the distribution of ARR_DELAY
#hist(dataset$ARR_DELAY, xlim = c(-100,500))
hist(dataset$ARR_DELAY, 2000, xlim = c(-60,120))

# -> The number of times ARR_DELAY>100mins is much lesser than -100 to 100mins range.
# -> Mean: 6.954, Median: -5.
# -> We could settle for 15mins blocks because majority of the delays are between -100 and 100 mins.
# Convert numerical ARR_DELAY into discrete categories, for multiclass classification
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
# -> Any number less than 0 is grouped as 'no delay', and numbers>0 are grouped in 15mins intervals,
# -> DELAY_GROUPS has 7 classes.
# -> This will be our reponse variable.

# 1.3 Preprocessing
# Convert FL_DATE feature from string type to date type
dataset$FL_DATE <- as.Date(dataset$FL_DATE, "%d/%m/%Y")

# Convert features to categorical type
#dataset$CARRIER <- factor(dataset$CARRIER)
dataset$ORIGIN_AIRPORT_ID <- factor(dataset$ORIGIN_AIRPORT_ID)
dataset$DEST_AIRPORT_ID <- factor(dataset$DEST_AIRPORT_ID)
dataset$MONTH <- factor(dataset$MONTH)
dataset$DAY_OF_MONTH <- factor(dataset$DAY_OF_MONTH)
dataset$DAY_OF_WEEK <- factor(dataset$DAY_OF_WEEK)

dataset$DEP_TIME_BINS <- cut(dataset$CRS_DEP_TIME,  breaks = c(1, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100,
                                                               1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100,
                                                               2200, 2300), right=FALSE)
levels(dataset$DEP_TIME_BINS) <- make.names(c("0000.to.0100", "0100.to.0159", "0200.to.0259", "0300.to.0359",
                                              "0400.to.0459", "0500.to.0559", "0600.to.0659", "0700.to.0759",
                                              "0800.to.0859", "0900.to.0959", "1000.to.1059", "1100.to.1159",
                                              "1200.to.1259", "1300.to.1359", "1400.to.1459", "1500.to.1559",
                                              "1600.to.1659", "1700.to.1759", "1800.to.1859", "1900.to.1959",
                                              "2000.to.2059", "2100.to.2159", "2200.to.2259", "2300.to.2359"))
dataset$ARR_TIME_BINS <- cut(dataset$CRS_ARR_TIME,  breaks = c(1, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100,
                                                               1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100,
                                                               2200, 2300), right=FALSE)
levels(dataset$ARR_TIME_BINS) <- make.names(c("0000.to.0100", "0100.to.0159", "0200.to.0259", "0300.to.0359",
                                              "0400.to.0459", "0500.to.0559", "0600.to.0659", "0700.to.0759",
                                              "0800.to.0859", "0900.to.0959", "1000.to.1059", "1100.to.1159",
                                              "1200.to.1259", "1300.to.1359", "1400.to.1459", "1500.to.1559",
                                              "1600.to.1659", "1700.to.1759", "1800.to.1859", "1900.to.1959",
                                              "2000.to.2059", "2100.to.2159", "2200.to.2259", "2300.to.2359"))
                             
# Add lat long into dataset (run section 12.3 before this)
ORIGIN_AIRPORT_LAT <- as.numeric(lookupLatitude(dataset$ORIGIN_AIRPORT_ID))
ORIGIN_AIRPORT_LONG <- as.numeric(lookupLongitude(dataset$ORIGIN_AIRPORT_ID))
DEST_AIRPORT_LAT <- as.numeric(lookupLatitude(dataset$DEST_AIRPORT_ID))
DEST_AIRPORT_LONG <- as.numeric(lookupLongitude(dataset$DEST_AIRPORT_ID))
dataset <- cbind(dataset,
                 ORIGIN_AIRPORT_LAT,
                 ORIGIN_AIRPORT_LONG,
                 DEST_AIRPORT_LAT,
                 DEST_AIRPORT_LONG)


# 1.4 Analyzing Causes of Delay ======================================================================================
attach(dataset)
delayedFlightsWithKnownReason <- subset(dataset, CARRIER_DELAY > 0 |
                                            NAS_DELAY > 0 |
                                            WEATHER_DELAY > 0 |
                                            SECURITY_DELAY > 0 |
                                            LATE_AIRCRAFT_DELAY > 0)
delayedFlightsWithWeatherAndAircraftDelay <- subset(dataset,  
                                                    WEATHER_DELAY > 0 &
                                                        LATE_AIRCRAFT_DELAY > 0)
totalNumDelayedFlights <- length(na.omit(DELAY_GROUPS[DELAY_GROUPS!="no delay"]))
numDelayedFlightsWithReason <- length(na.omit(delayedFlightsWithKnownReason$DELAY_GROUPS))
numDelayedFlightsWithUnknownReason <- totalNumDelayedFlights - numDelayedFlightsWithReason
reason1 <- length(na.omit(CARRIER_DELAY[CARRIER_DELAY>0]))
reason2 <- length(na.omit(NAS_DELAY[NAS_DELAY>0]))
reason3 <- length(na.omit(WEATHER_DELAY[WEATHER_DELAY>0]))
reason4 <- length(na.omit(SECURITY_DELAY[SECURITY_DELAY>0]))
reason5 <- length(na.omit(LATE_AIRCRAFT_DELAY[LATE_AIRCRAFT_DELAY>0]))

par(mai = c(1,2,0.5,0.5))
barplot(c(numDelayedFlightsWithUnknownReason,reason1,reason2,reason3,reason4,reason5),
        horiz = TRUE,
        las = 1,
        main = "Reasons for Flight Delays",
        xlab = "Number of Delayed Flights",
        names.arg = c("Reason Not Given","Carrier","National Air Service","Weather","Security","Late Aircraft"),
        cex.names = 1.0
)
par(mai = c(0.5,0.5,0.5,0.5))
hist(na.omit(CARRIER_DELAY[CARRIER_DELAY>0]), breaks = 1000, xlim = c(-60,240))
hist(na.omit(NAS_DELAY[NAS_DELAY>0]), breaks = 1000, xlim = c(-10,60))
hist(na.omit(WEATHER_DELAY[WEATHER_DELAY>0]), breaks = 1000, xlim = c(-60,240))
hist(na.omit(SECURITY_DELAY[SECURITY_DELAY>0]), breaks = 1000, xlim = c(-60,240))
hist(na.omit(LATE_AIRCRAFT_DELAY[LATE_AIRCRAFT_DELAY>0]), breaks = 1000, xlim = c(-60,240))

d1_carrierDelayedFlighs <- subset(delayedFlights, CARRIER_DELAY > 0)
d2_nasDelayedFlights <- subset(delayedFlights, NAS_DELAY > 0)
d3_weatherDelayedFlights <- subset(delayedFlights, WEATHER_DELAY > 0)
d4_securityDelayedFlights <- subset(delayedFlights, SECURITY_DELAY > 0)
d5_lateAircraftDelayedFlights <- subset(delayedFlights, LATE_AIRCRAFT_DELAY > 0)
d6_lateFlights <- subset(dataset, DELAY_GROUPS != "no delay")
percentageAllFlightsWeatherDelayed <- 5661/450018
percentageAllFlightsWeatherDelayed
percentageDelayedFlightsWithKnownCauseWeatherDelayed <- 5661/97699
percentageDelayedFlightsWithKnownCauseWeatherDelayed

delayedFlights <- subset(dataset, ARR_DELAY > 0) 
#create box plots for categorical features correlation since TKTau has too many question marks
boxplot(delayedFlights$ARR_DELAY~delayedFlights$DAY_OF_WEEK,data=delayedFlights, main="Delay on each weekday", 
        xlab="Day of Week", ylab="Delay", outline = F)
boxplot(delayedFlights$CRS_DEP_TIME~delayedFlights$DELAY_GROUPS,data=delayedFlights, main="Delay group and departure time", 
        xlab="Delay Group", ylab="Departure Time", outline = F)
# dataset$NAS_DELAY
# dataset$WEATHER_DELAY
# dataset$SECURITY_DELAY
# dataset$LATE_AIRCRAFT_DELAY

# 1.5 Plotting Latitude and Longitude ================================================================================
# -> Reference: https://rstudio-pubs-static.s3.amazonaws.com/254085_f70afc81201b40c8989091a3e6173dc1.html
# Define Map parameters
bbox2 <- make_bbox(dataset$DEST_AIRPORT_LONG, dataset$DEST_AIRPORT_LAT, f = .00001)

# Create Map
map <- openmap(c(bbox2[4], bbox2[1]), c(bbox2[2], bbox2[3]), type = "esri")
map <- openproj(map)

# All Airports
# Plot
p0 <- autoplot(map)
# Plot Points
p <- p0 + geom_point(
    aes(x = DEST_AIRPORT_LONG, y = DEST_AIRPORT_LAT),
    data = dataset,
    alpha = 1,
    size = 0.5
) + ggtitle("Airports in the USA")
p1 <- p + geom_point(aes(x = DEST_AIRPORT_LONG, y = DEST_AIRPORT_LAT, size = ARR_DELAY ), 
                     colour  =  I(alpha("black", 5/10)), data = dataset) +
    scale_size(name = "Arrival\nDelays", breaks = c(15, 30, 45, 60, 120), 
               labels = c("<15 min",  "15 to 30min", "30 to 45min", "45 to 60min", ">120mins"), limits = c(0,1000))

p1
# -> Need to increase the resolution of the map, 
# -> and suggest what how else do we wanna make use of longitude and langitude
# -> Spent way too much time on plotting this map



# 1.9 Spliting the dataset ============================================================================
# -> Data is split in 2 different sets: training and testing sets

# Shrink the dataset to train our models faster, 10%
# cutoff = round(0.1*nrow(dataset))
# dataset <- dataset[1:cutoff,]
# create a list of 70% of the rows in the original dataset we can use for training
set.seed(7)
test.index <- createDataPartition(dataset$DELAY_GROUPS, p=0.7, list=FALSE)
# select 30% of the data for testing
testdf.unprocessed <- dataset[-test.index,]
# use the remaining 70% of data for creating training dataset
traindf.unprocessed <- dataset[test.index,]


# 2.0 Analyse Data ============================================================================================

head(traindf.unprocessed)
dim(traindf.unprocessed)
# -> We have 315016 instances to work with and 22 features/attributes.

str(traindf.unprocessed)

# Looking at what type of features do we have to work with
sapply(traindf.unprocessed, class)
# -> class types of some features have to be converted to factors

# Look at which feature has missing values
describe(traindf.unprocessed)
# -> ARR_DELAY feature has 10372 missing values, CRS_ELAPSED_TIME has 4 missing values,
#    CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY has 352318 missing values.


# 3.0 Visualize traindf.unprocessed ================================================================================

# Creating functions for plotting 
# Reference: https://www.kaggle.com/notaapple/detailed-exploratory-data-analysis-using-r
plotHist <- function(data_in, i) {
    data <- data.frame(x=data_in[[i]])
    p <- ggplot(data=data, aes(x=factor(x))) + stat_count() + xlab(colnames(data_in)[i]) + theme_light() + 
        theme(axis.text.x = element_text(angle = 90, hjust =1))
    return (p)
}

plotDen <- function(data_in, i){
    data <- data.frame(x=data_in[[i]], delay_groups = data_in$DELAY_GROUPS)
    p <- ggplot(data= data) + geom_line(aes(x = x), stat = 'density', size = 1,alpha = 1.0) +
        xlab(paste0((colnames(data_in)[i]), '\n', 'Skewness: ',round(skewness(data_in[[i]], na.rm = TRUE), 2))) + theme_light() 
    return(p)
    
}
doPlots <- function(data_in, fun, ii, ncol=3) {
    pp <- list()
    for (i in ii) {
        p <- fun(data_in=data_in, i=i)
        pp <- c(pp, list(p))
    }
    do.call("grid.arrange", c(pp, ncol=ncol))
}

# 3.1 Create Histograms and Kernel density plots for each numerical feature
doPlots(traindf.unprocessed, fun = plotDen, ii = 1:3, ncol = 2)
doPlots(traindf.unprocessed, fun = plotDen, ii = 8:12, ncol = 2)
doPlots(traindf.unprocessed, fun = plotDen, ii = 13:17, ncol = 2)
doPlots(traindf.unprocessed, fun = plotHist, ii = 8:9, ncol = 1)

# 3.2 Create barplots for each categorical feature
doPlots(traindf.unprocessed, fun = plotHist, ii = 5, ncol = 1)
doPlots(traindf.unprocessed, fun = plotHist, ii = 20, ncol = 1)
# -> Looking at the frequencies for our response variable, its distribution follows a right skew.

# 4.0 Cleaning Data ============================================================================================

# 4.1 Handling missing data
colSums(sapply(dataset, is.na))
# -> There are 10372 rows with missing ARR_DELAY values.
# -> Action? Since 10372 rows is just 2.3% of the total number of rows, we can remove the rows with missing values
# Visualisation of missing data
plot_Missing <- function(data_in, title = NULL){
    temp_df <- as.data.frame(ifelse(is.na(data_in), 0, 1))
    temp_df <- temp_df[,order(colSums(temp_df))]
    data_temp <- expand.grid(list(x = 1:nrow(temp_df), y = colnames(temp_df)))
    data_temp$m <- as.vector(as.matrix(temp_df))
    data_temp <- data.frame(x = unlist(data_temp$x), y = unlist(data_temp$y), m = unlist(data_temp$m))
    ggplot(data_temp) + geom_tile(aes(x=x, y=y, fill=factor(m))) + scale_fill_manual(values=c("white", "black"), name="Missing\n(0=Yes, 1=No)") + theme_light() + ylab("") + xlab("") + ggtitle(title)
}

plot_Missing(dataset[,(colSums(is.na(dataset)) > 0)], title = "Missing Values")

# 4.2 Remove rows with missing ARR_DELAY and CRS_ELAPSED_TIME values
dataset <- dataset %>% 
    filter(!is.na(ARR_DELAY)) %>%
    filter(!is.na(DEP_TIME_BINS))  %>%
    filter(!is.na(ARR_TIME_BINS))
describe(dataset)

# 5.0 Feature Engineering ==========================================================

# One-Hot-Encode categorical features
# -> we use OHE to perform “binarization??? of the categories and include them as a feature to train the model.
# -> OHE transforms categorical features to a format that works better with classification and regression algorithms.
# -> However, algorithms like randomF handles categorical features natively, so OHE is no necessary.

# -> Before we OHE, we must convert our response variable to numerical, 
#    because the following code transforms all factor type (categorical) features into OHE format.
#    We don't want to OHE our reponse variable, we want it to stay as a factor type for modelling purposes.
included.features <- c("DELAY_GROUPS", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "CARRIER", "ORIGIN_AIRPORT_ID",
                       "DEST_AIRPORT_ID", "CRS_DEP_TIME", "CRS_ARR_TIME", 
                       "DISTANCE", "ORIGIN_AIRPORT_LAT", "ORIGIN_AIRPORT_LONG", "DEST_AIRPORT_LAT",
                       "DEST_AIRPORT_LONG")
included.features <- c("ARR_DELAY", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "CARRIER", "ORIGIN_AIRPORT_ID",
                       "DEST_AIRPORT_ID", "CRS_DEP_TIME", "CRS_ARR_TIME", 
                       "DISTANCE", "ORIGIN_AIRPORT_LAT", "ORIGIN_AIRPORT_LONG", "DEST_AIRPORT_LAT",
                       "DEST_AIRPORT_LONG")
included.features <- c("ARR_DELAY", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "CARRIER", "ORIGIN_AIRPORT_ID",
                       "DEST_AIRPORT_ID", "DEP_TIME_BINS", "ARR_TIME_BINS", "DISTANCE")
dataset <- dataset[included.features]
dataset$DELAY_GROUPS <- as.numeric(dataset$DELAY_GROUPS)
# One-Hot-Encode all factor type features, put all encoded features into new dataset.ohe
dmy <- dummyVars(" ~ .", data = dataset)
dataset.ohe <- data.frame(predict(dmy, newdata = dataset))

# Change response variable back to factor type
dataset.ohe$DELAY_GROUPS <- factor(dataset.ohe$DELAY_GROUPS)
dataset$DELAY_GROUPS <- factor(dataset$DELAY_GROUPS)

# Make valid names for response variable's classes since some models require valid names to work.
levels(dataset$DELAY_GROUPS) <- make.names(c("no_delay",
                                             "delay.1.to.15.mins",
                                             "delay.16.to.30.mins",
                                             "delay.31.to.45.mins",
                                             "delay.46.to.60.mins",
                                             "delay.61.to.120.mins",
                                             "delay.121.mins.or.more"))
levels(dataset.ohe$DELAY_GROUPS) <- make.names(c("no_delay",
                                                 "delay.1.to.15.mins",
                                                 "delay.16.to.30.mins",
                                                 "delay.31.to.45.mins",
                                                 "delay.46.to.60.mins",
                                                 "delay.61.to.120.mins",
                                                 "delay.121.mins.or.more"))


# 6.0 Train/Test split ============================================================================
# -> Data is split in 2 different sets: training and testing sets

# Shrink the dataset to train our models faster, 10%
cutoff = round(0.1*nrow(dataset))
dataset <- dataset[1:cutoff,]
cutoff.ohe = round(0.1*nrow(dataset.ohe))
dataset.ohe <- dataset.ohe[1:cutoff.ohe,]
# Use the same index we used to split earlier
set.seed(7)
#test.index <- createDataPartition(dataset$DELAY_GROUPS, p=0.7, list=FALSE)
test.index <- createDataPartition(dataset$ARR_DELAY, p=0.7, list=FALSE)
# Select 30% of the data for testing
testdf <- dataset[-test.index,]
# Use the remaining 70% of data for creating training dataset
traindf <- dataset[test.index,]

# Create train and test sets for one-hot-encoded dataset as well
testdf.ohe <- dataset.ohe[-test.index,]
traindf.ohe <- dataset.ohe[test.index,]

# 7.0 Correlations between categorical variables ==============================================================

# Check for relationships between all categorical variables
subset <- c(5:7, 1)
GKmatrix <- GKtauDataframe(traindf[,subset])
plot(GKmatrix)
# -> The Goodman-Kruskal tau measure: knowledge of marital.status is predictive of relationship, and similar otherwise.
# -> Reference: https://cran.r-project.org/web/packages/GoodmanKruskal/vignettes/GoodmanKruskal.html

# 7.5 Correlations between numerical variables ============================================================

# -> To show this, we combining correlogram with the significance test, 
# -> Reference: http://www.sthda.com/english/wiki/visualize-correlation-matrix-using-correlogram
# Build a function to compute a matrix of p-values
cor.mtest <- function(mat, ...) {
    mat <- as.matrix(mat)
    n <- ncol(mat)
    p.mat<- matrix(NA, n, n)
    diag(p.mat) <- 0
    for (i in 1:(n - 1)) {
        for (j in (i + 1):n) {
            tmp <- cor.test(mat[, i], mat[, j], ...)
            p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
        }
    }
    colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
    p.mat
}
cor <- cor(traindf[,c(2:3,7:12)])
p.mat <- cor.mtest(traindf[,c(2:3,7:12)])

# Build a correlogram
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(cor, method="color", col=col(200),  
         type="upper", order="hclust", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE)
# -> correlations with p-value > 0.05 are considered as insignificant, and crosses are added for those.
# -> Don't seem to have any correlation among numerical variables, which is a good thing.



# 8.0 Evaluate Algorithms =======================================================
control <- trainControl(
    method = "cv",
    number = 5,
    verboseIter = TRUE,
    returnData = FALSE,
    returnResamp = "all",                       # save losses across all models
    #classProbs = TRUE,                          # set to TRUE for AUC to be computed
    #summaryFunction=multiClassSummary,
    #summaryFunction=mnLogLoss,
    allowParallel = TRUE
)
# -> The function trainControl can be used to specifiy the type of resampling,
#    in this case, 5-fold cross validation.
metric <- "Accuracy" 
metric <- "ROC" # Should use this!!
metric <- "logLoss"
metric <- "RMSE"

# -> Algorithms:
# -> CART
# -> LogitBoost - Boosted Logistic Regression
# -> xgbTree - eXtreme Gradient Boosting
# -> NNET - Neural Network
# -> MLP - Multi-Layer Perceptron

# -> All timings recording are trained on 10% of data

# Regression attempt
xgbTreeGrid <- expand.grid(nrounds = c(100,200), max_depth = seq(7,10,by = 1), eta = 0.1, 
                           gamma = 0, colsample_bytree = 1.0,  subsample = 1.0, min_child_weight = 4)
set.seed(7)
system.time(fit.xgb.reg <- caret::train(ARR_DELAY ~., data = traindf.ohe, trControl = control,
                                    tuneGrid = xgbTreeGrid, metric = metric, method = "xgbTree", nthread=4))
set.seed(7)
system.time(fit.lm <- caret::train(ARR_DELAY ~., data = traindf, trControl = control,
                                       metric = metric, method = "lm"))
# -> 198.81
set.seed(7)
system.time(fit.lm1 <- caret::train(ARR_DELAY ~., data = traindf.ohe, trControl = control,
                                       metric = metric, method = "lm"))
# -> 189.92 
set.seed(7)
system.time(fit.lm2 <- caret::train(ARR_DELAY ~.-ORIGIN_AIRPORT_LAT-ORIGIN_AIRPORT_LONG-DEST_AIRPORT_LAT-DEST_AIRPORT_LONG,
                                    data = traindf.ohe, trControl = control,
                                    metric = metric, method = "lm"))

set.seed(7)
system.time(fit.glm <- caret::train(ARR_DELAY~., data=traindf.ohe, method="glm", metric=metric, trControl=control))
# -> 437.04
set.seed(7)
system.time(fit.glmnet <- caret::train(ARR_DELAY~., data=traindf.ohe, method="glmnet", metric=metric, trControl=control))
# -> 275.94 
set.seed(7)
system.time(fit.nn <- caret::train(ARR_DELAY~., data=traindf.ohe, method="nnet", metric=metric, trControl=control))
# -> 4876.75
set.seed(7)
system.time(fit.bsttree <- caret::train(ARR_DELAY~., data=traindf, method="bstTree", metric=metric, trControl=control))

# eXtreme Gradient Boosting ********************************************************************************

xgbgrid <- expand.grid(
    nrounds = c(100,200),
    eta = 0.01,
    max_depth = c(9,10),
    gamma = 0,
    colsample_bytree = c(0.4,0.5),
    min_child_weight = 1,
    subsample = 1
)
set.seed(7)
system.time(fit.xgb <- caret::train(DELAY_GROUPS ~ ., data = traindf.ohe, trControl = control,
                                    tuneGrid = xgbgrid, metric = metric, method = "xgbTree",
                                    verbose = 1, num_class = 7))
# -> fit.xgb: 7680.36  sec elapsed
# -> Fitting nrounds = 200, max_depth = 10, eta = 0.01, gamma = 0, colsample_bytree = 0.5, min_child_weight = 1, subsample = 1 on full training set
fit.xgb$bestTune
plot(fit.xgb)

predictions.xgb<-predict(fit.xgb,testdf.ohe)
caret::confusionMatrix(predictions.xgb, testdf.ohe$DELAY_GROUPS)


# Boosted Logistic Regression ********************************************************************************
set.seed(7)
system.time(fit.LogitBoost <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="LogitBoost", 
                                           metric=metric, trControl=control))
# -> fit.logitboost: 927.15
set.seed(7)
system.time(fit.LogitBoost1 <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="LogitBoost", 
                                            metric=metric, trControl=control,
                                            preProcess = c('BoxCox')))
# -> fit.logitboost1: 948.52

# CART ********************************************************************************
set.seed(7)
system.time(fit.cart <- caret::train(DELAY_GROUPS~., data=traindf, method="rpart",
                                     parms = list(split = "information"), #or 'information'
                                     metric=metric, trControl=control, tuneLength = 10))
# -> fit.cart: 540.52 
set.seed(7)
system.time(fit.cart1 <- caret::train(DELAY_GROUPS~., data=traindf, method="rpart",
                                      parms = list(split = "gini"), #or 'information'
                                      metric=metric, trControl=control, tuneLength = 10))
# -> fit.cart1: 557.76   
set.seed(7)
system.time(fit.cart2 <- caret::train(DELAY_GROUPS~.-CRS_ELAPSED_TIME, data=traindf, method="rpart",
                                      parms = list(split = "gini"), #or 'information'
                                      metric=metric, trControl=control, tuneLength = 10))
# -> fit.cart1: 557.76
set.seed(7)
system.time(fit.cart3 <- caret::train(DELAY_GROUPS~.-CRS_ELAPSED_TIME, data=traindf, method="rpart",
                                      parms = list(split = "information"), #or 'information'
                                      metric=metric, trControl=control, tuneLength = 10))
# -> fit.cart1: 557.76  
predictions.caret2<-predict(fit.cart2,testdf)
caret::confusionMatrix(predictions.caret2, testdf$DELAY_GROUPS)
predictions.caret1<-predict(fit.cart1,testdf)
caret::confusionMatrix(predictions.caret1, testdf$DELAY_GROUPS)


# Neural Network ********************************************************************************
nnetGrid <-  expand.grid(size = seq(from = 1, to = 10, by = 1),
                         decay = seq(from = 0.1, to = 0.5, by = 0.1))

set.seed(7)
system.time(fit.nnet <- caret::train(DELAY_GROUPS~., data=traindf, method="nnet", 
                                     metric=metric, trControl=control))
# -> fit.nnet: 334.23 
set.seed(7)
system.time(fit.nnet1 <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="nnet", 
                                      metric=metric, trControl=control, preProcess = 'BoxCox',
                                      tuneLength = 10))
# -> fit.nnet1: 574.64 
set.seed(7)
system.time(fit.nnet2 <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="nnet", 
                                      metric=metric, trControl=control, tuneGrid = nnetGrid))
# -> fit,nnet2: 2527. 
#The final values used for the model were size = 1 and decay = 0.4.

# -> Turns out performance is the same regardless of BoxCox transformation and encoding.

# Multi-Layer Perceptron ********************************************************************************
set.seed(7)
system.time(fit.mlp <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="mlp", 
                                    preProcess = 'BoxCox', 
                                    metric="Accuracy", trControl=control))
# -> fit.mlp: 794.86


# Yet to run ********************************************************************************************
set.seed(7)
system.time(fit.LogitBoost <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="LogitBoost", 
                                           metric="Accuracy", trControl=control, tuneLength = 10))

set.seed(7)
system.time(fit.gbm <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="gbm", 
                                    metric="Accuracy", trControl=control))

xgbgrid2 <- expand.grid(max_depth=c(seq(from = 2, to = 10, by = 1)),
                        eta=c(seq(from = 0.1, to = 1, by = 0.3)),
                        nrounds=c(seq(from = 1, to = 500, by = 50)),
                        colsample_bytree=c(seq(from = 0.5, to = 1, by = 0.1)),
                        min_child_weight=c(seq(from = 0.1, to = 1, by = 0.4)),
                        subsample=c(seq(from = 0.1, to = 1, by = 0.4)),
                        gamma =c(seq(from = 0.1, to = 1, by = 0.4))
)
set.seed(7)
system.time(fit.xgb1 <- caret::train(DELAY_GROUPS ~ ., data = traindf.ohe, trControl = control,
                                     tuneGrid = xgbgrid2, metric = "Accuracy", method = "xgbTree",
                                     verbose = 1, num_class = 7))

set.seed(7)
system.time(fit.ada <- caret::train(DELAY_GROUPS~., data=traindf.ohe, method="ada", 
                                   metric=metric, trControl=control))
print(fit.xgbLinear_1)
#plot(fit.xgbLinear_1)

library(mlbench)
control.rfe <- rfeControl(functions=nbFuncs, method="cv", number=10)
# run the RFE algorithm
results <- rfe(traindf[,2:14], traindf[,1], sizes=c(1:14), rfeControl=control.rfe)

# 9.0 Compare algorithms =============================================================
# collect resampling statistics of ALL trained models
results <- resamples(list( 
    #LogitBoost   = fit.LogitBoost,
    #LogitBoost1   = fit.LogitBoost1,
    #Cart          = fit.cart,
    #Cart1         = fit.cart1,
    #Cart2         = fit.cart2
    #XGBTree       = fit.xgb,
    #NNET          = fit.nnet,
    #NNET1         = fit.nnet1,
    #NNET2         = fit.nnet2
    #MLP           = fit.mlp
    lm            = fit.lm,
    lm1            = fit.lm1,
    lm2            = fit.lm2
))

# Summarize the fitted models
summary(results)
# Plot and rank the fitted models
dotplot(results)
dotplot(results, metric=metric)

# Test skill of the BEST trained model on validation/testing dataset
predictions.LogitBoost1 <- predict(fit.LogitBoost, newdata=testdf.ohe)
predictions.xgb <- predict(fit.xgb, newdata=testdf.ohe)
predictions.cart.prob <- predict(fit.cart, newdata = testdf, type='prob')
# Evaluate the BEST trained model and print results
result.LogitBoost1 <- caret::confusionMatrix(predictions.LogitBoost1, testdf.ohe$DELAY_GROUPS)
result.xgb <- caret::confusionMatrix(predictions.xgb, testdf.ohe$DELAY_GROUPS)
# summarize Best Model
print(result.LogitBoost1) 
# ->  Accuracy : 0.6935
# ->  Basically it's predicting all as no delay, this is really bad...
# ->  Very misleading to use accuracy as a metric. Should we use Area under ROC?
print(result.xgb) 
# -> Accuracy : 0.6433 
# -> Predictions are spreaded nicely throughout 7 classes.
# -> I picked this because fit.xgb gives the best cv AUC score.


# 11.0 Visualising Results =========================================================================================
# Create a ROC plot comparing performance of all models
# colors <- randomColor(count = 10, hue = c("random"), luminosity = c("dark"))
# roc1 <- roc(testdf$annual.income, predictions.stack.glm5.prob, col=colors[1], percent=TRUE, asp = NA,
#             plot=TRUE, print.auc=TRUE, grid=TRUE, main="ROC comparison", print.auc.x=70, print.auc.y=80)
# roc2 <- roc(testdf$annual.income, predictions.stack.rpart6.probs, plot=TRUE, add=TRUE, 
#             percent=roc1$percent, col=colors[2], print.auc=TRUE, print.auc.x=70, print.auc.y=70)
# roc3 <- roc(testdf$annual.income, predictions.C50.prob, plot=TRUE, add=TRUE, 
#             percent=roc1$percent, col=colors[3], print.auc=TRUE, print.auc.x=70, print.auc.y=60)
# roc4 <- roc(testdf$annual.income, predictions.cart.prob, plot=TRUE, add=TRUE, 
#             percent=roc1$percent, col=colors[4], print.auc=TRUE, print.auc.x=70, print.auc.y=50)
# roc5 <- roc(testdf$annual.income, predictions.lda1.prob, plot=TRUE, add=TRUE, 
#             percent=roc1$percent, col=colors[5], print.auc=TRUE, print.auc.x=70, print.auc.y=40)
# roc6 <- roc(testdf$annual.income, predictions.logit5.prob, plot=TRUE, add=TRUE, 
#             percent=roc1$percent, col=colors[6], print.auc=TRUE, print.auc.x=70, print.auc.y=30)
# legend("bottomright", legend=c("stack.glm", "stack.rpart", "C5.0", "CART", "LDA", "logistic"), col=c(colors[1:6]), lwd=2)

# 12.0 Function Implementation ================================================================================
# -> https://jessesw.com/Air-Delays/ 
# -> Converted the function implementation of link from python code to R code. Very time consuming.
# -> Final function is still not ready, but it's close to done
# -> We still need to build a function that retrieves longitude and latitude for the final function to work.

# 12.1 max_num_flights function
# -> max_num_flights is a function for the delay prediction function to use for calculating the number of 
#    flights in the database for a given city.
# -> Inputs: list of codes retrived in the delay_prediction function
# -> Output: The code with the largest number of flights.
max_num_flights <- function(codes) {
    # Array to store all airport codes
    num_store <- list()
    
    if (length(codes)<1) {
        print('Try entering your city/airport again. No matching airports found.')
        return
    }
    for (i in 1:length(codes)) {
        num_flights <- sum(grepl(codes[i],dataset$ORIGIN_AIRPORT_ID))
        num_store[i] <- num_flights  
    }
    # Now find the maximum row  
    max_num_store <- max(unlist(num_store))
    max_ind = match(max_num_store, num_store)
    # Now we know which code had the most flights. Return it.
    return(codes[max_ind])
}
codes <- c(13930, 11298)
codes1 <- c(11703,12478, 12541, 12545, 12546, 12548, 12953, 13784, 15346, 15859)
max_num_flights(codes1)

df <- data.frame()
df[1,1] <- 1
df[1,2] <- 1

# 12.2 delay_prediction function
# -> The function will allow the user to enter all of the information about their flight 
# -> and return the predicted delay time in minutes. 
delay_prediction <- function(origin = 'Fort Worth', destination = 'Chicago', carrier = 'American', 
                             dept_time = 17, arr_time = 19, month = 5, day = 15, weekday = 'Wednesday') {
    
    # Create a dict for our Airlines. Based on the carrierDF.
    carrier_dict <- list('Endeavor'=1, 'American'=2, 'Alaska'=3, 'JetBlue'=4, 'Delta'=5,
                         'ExpressJet'=6, 'Frontier'=7, 'AirTran'=8, 'Hawaiian'=9, 'Envoy'=10,
                         'SkyWest'=11, 'United'=12, 'US Airways'=13, 'Virgin'=14,
                         'Southwest'=15, 'Mesa'=16)
    
    # Another for day of the week
    
    weekday_dict <- list('Monday'=1, 'Tuesday'=2, 'Wednesday'=3, 'Thursday'=4,
                         'Friday'=5, 'Saturday'=6, 'Sunday'=7)
    
    # Now find the corresponding airport codes for our origin and destination. 
    
    #origin_codes = list(airport_lookupDF[airport_lookupDF.Description.str.contains(origin)].Code)
    origin_codes <- grep(origin, airport_lookupDF$Description)
    #destination_codes = list(airport_lookupDF[airport_lookupDF.Description.str.contains(destination)].Code)
    destination_codes <- grep(destination, airport_lookupDF$Description)
    
    # From these codes found in the lookup table, see which one had the largest number of flights.
    
    origin_code <- max_num_flights(as.list(airport_lookupDF[origin_codes,][1])$Code)
    destination_code <- max_num_flights(as.list(airport_lookupDF[destination_codes,][1])$Code)
    
    # Now that we have these codes, we can look up the other parameters necessary.
    
    
    # Now find the distance between the two airports.
    
    distance <- dataset$DISTANCE[dataset$ORIGIN_AIRPORT_ID==origin_code & dataset$DEST_AIRPORT_ID==destination_code][1]
    
    carrier_num <- carrier_dict$carrier
    weekday_num <- weekday_dict$weekday
    
    # Now that we have all of our values, we can start combining them together
    
    # Now create our array of categorical values.
    
    categorical_values = data.frame()
    categorical_values[1,1] = as.numeric(day)
    categorical_values[1,2] = as.numeric(weekday_num)
    categorical_values[1,3] = as.factor(carrier_num)
    categorical_values[1,4] = as.factor(origin_code)
    categorical_values[1,5] = as.factor(destination_code)
    categorical_values[1,6] = as.numeric(dept_time)
    categorical_values[1,7] = as.numeric(arr_time)
    categorical_values[1,8] = as.numeric(arr_time-dept_time)
    categorical_values[1,9] = as.numeric(distance)
    categorical_values[1,10] = as.numeric(long)
    categorical_values[1,11] = as.numeric(lat)
    
    # Apply the one-hot encoding to these.
    dmy1 <- dummyVars(" ~ .", data = categorical_values)
    categorical_values.ohe <- data.frame(predict(dmy1, newdata = categorical_values))
    
    
    # Now predict this with the model 
    
    prediction <- predict(fit.LogitBoost1, newdata=testdf.ohe)
    print ('Your prediction delay is', prediction[0])
    return # End of function
}
# 12.3 lookupAirportData function =======================================================
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
LATITIUDE_LIST <- airportData$LATITUDE
LONGITUDE_LIST <- airportData$LONGITUDE

# Function Definitions ===================================================================
lookupAirportData <- function(AIRPORT_ID, RETURN) {
    row.index <- match(AIRPORT_ID,AIRPORT_ID_LIST)
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



# 13.0 Conclusions ===================================================================================================


