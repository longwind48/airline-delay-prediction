  #1. Average length of delay per feature
  data=dataForAnalysisOfCausesOfDelay
  #1.1 Carrier
  data$AVE_DELAY_CARRIER=ave(data$ARR_DELAY,data$CARRIER)
  png(filename = "plots/1.1Average_length_of_delay_per_carrier.png")
  ggplot(data,aes(x=reorder(data$CARRIER,-data$AVE_DELAY_CARRIER),
                  y=data$AVE_DELAY_CARRIER,
                  group = 1))+
    geom_line()+
    geom_point()+
    ggtitle("Average Length of Delay per Carrier") +
    xlab("Carrier") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  delayedFlights <- subset(data,data$CARRIER_DELAY > 15)
  bymedian <- with(delayedFlights, 
                   reorder(delayedFlights$CARRIER,delayedFlights$ARR_DELAY, median))
  png(filename = "plots/1.1box_plot_Average_length_of_delay_per_carrier.png")
  boxplot(delayedFlights$ARR_DELAY~bymedian,
          data=delayedFlights,
          main="Boxplot Arrival Delay per Carrier", 
          xlab="Carrier",
          ylab="Arrival Delay(min)",
          outline = F)#keep, cuz it shows some significant results
  dev.off()
  
  #1.2 State
  data$AVE_DELAY_ORIGIN_STATE=ave(data$ARR_DELAY,data$ORIGIN_AIRPORT_STATE_NAME)
  data$AVE_DELAY_DEST_STATE=ave(data$ARR_DELAY,data$DEST_AIRPORT_STATE_NAME)
  #put data in decreasing order of y-axis
  png(filename = "plots/1.2Average_length_of_delay_per_origin_state.png")
  ggplot(data,aes(x=reorder(data$ORIGIN_AIRPORT_STATE_NAME,-data$AVE_DELAY_ORIGIN_STATE),
                  y=data$AVE_DELAY_ORIGIN_STATE,
                  group = 1))+
    geom_point()+geom_line()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    ggtitle("Average Length of Delay per Origin State") +
    xlab("Origin State") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  png(filename = "plots/1.2Average_length_of_delay_per_dest_state.png")
  ggplot(data,aes(x=reorder(data$DEST_AIRPORT_STATE_NAME,-data$AVE_DELAY_DEST_STATE),
                  y=data$AVE_DELAY_DEST_STATE,
                  group=1))+
    geom_point()+geom_line()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    ggtitle("Average Length of Delay per Destination State") +
    xlab("Destination State") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #1.3 Longitude & Lat
  #origin
  data$AVE_DELAY_ORIGIN_LONG=ave(data$ARR_DELAY,data$ORIGIN_AIRPORT_LONG)
  data$AVE_DELAY_ORIGIN_LAT=ave(data$ARR_DELAY,data$ORIGIN_AIRPORT_LAT)
  png(filename = "plots/1.3Average_length_of_delay_orgin_long.png")
  ggplot(data,aes(x=data$ORIGIN_AIRPORT_LONG,
                  y=data$AVE_DELAY_ORIGIN_LONG))+
    geom_point()+geom_line()+
    xlim(-160,-60)+
    ggtitle("Average Length of Delay-Origin Longitude") +
    xlab("Origin Longitude") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  png(filename = "plots/1.3Average_length_of_delay_orgin_lat.png")
  ggplot(data,aes(x=data$ORIGIN_AIRPORT_LAT,y=data$AVE_DELAY_ORIGIN_LAT))+
    geom_point()+geom_line()+
    ggtitle("Average Length of Delay-Origin Latitude") +
    xlab("Origin Latitude") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #destination
  data$AVE_DELAY_DEST_LONG=ave(data$ARR_DELAY,data$DEST_AIRPORT_LONG)
  data$AVE_DELAY_DEST_LAT=ave(data$ARR_DELAY,data$DEST_AIRPORT_LAT)
  png(filename = "plots/1.3Average_length_of_delay_dest_long.png")
  ggplot(data,aes(x=data$DEST_AIRPORT_LONG,y=data$AVE_DELAY_DEST_LONG))+
    geom_point()+geom_line()+
    xlim(-160,-60)+
    ggtitle("Average Length of Delay-Dest Longitude") +
    xlab("Dest Longitude") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  png(filename = "plots/1.3Average_length_of_delay_dest_lat.png")
  ggplot(data,aes(x=data$DEST_AIRPORT_LAT,y=data$AVE_DELAY_DEST_LAT))+
    geom_point()+geom_line()+
    ggtitle("Average Length of Delay-Dest Latitude") +
    xlab("Dest Latitude") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #1.4 TIME ANALYSIS
  #not put in order by value of AVE_DELAY_HOUR_DEP 
  #to keep the time order cuz it's intuitive to see)
  #1.4.1 Month
  data$MONTH=as.factor(data$MONTH)
  data$AVE_DELAY_MONTH=ave(data$ARR_DELAY,data$MONTH)
  png(filename = "plots/1.4.1Average_length_of_delay_month.png")
  ggplot(data,aes(x=data$MONTH,y=data$AVE_DELAY_MONTH,group=1))+
    geom_point()+geom_line()+
    ggtitle("Average Length of Delay per Month") +
    xlab("Month") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #1.4.2 day of week
  data$AVE_DELAY_WEEKDAY=ave(data$ARR_DELAY,data$DAY_OF_WEEK)
  png(filename = "plots/1.4.2Average_length_of_delay_day_of_week.png")
  ggplot(data,aes(x=data$DAY_OF_WEEK,y=data$AVE_DELAY_WEEKDAY,group=1))+
    geom_point()+geom_line()+
    ggtitle("Average Length of Delay each Day of Week") +
    xlab("Day of Week") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #1.4.3 Hour of day(hour bin)
  data$AVE_DELAY_HOUR_DEP=ave(data$ARR_DELAY,data$DEP_TIME_BINS)
  data$AVE_DELAY_HOUR_ARR=ave(data$ARR_DELAY,data$ARR_TIME_BINS)
  png(filename = "plots/1.4.3Average_length_of_delay_dep_hour.png")
  ggplot(data,aes(x=data$DEP_TIME_BINS,
                  y=data$AVE_DELAY_HOUR_DEP,
                  group=1))+
    geom_point()+geom_line()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    ggtitle("Average Length of Delay per Departure Hour") +
    xlab("Departure Hour") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  png(filename = "plots/1.4.3Average_length_of_delay_arr_hour.png")
  ggplot(data,aes(x=data$ARR_TIME_BINS,
                  y=data$AVE_DELAY_HOUR_ARR,
                  group=1))+
    geom_point()+geom_line()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    ggtitle("Average Length of Delay per Arrival Hour") +
    xlab("Arrival Hour") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #1.4.4 Duration/Distance
  data$AVE_DELAY_DURATION=ave(data$ARR_DELAY,round(data$CRS_ELAPSED_TIME,digits = -1))
  png(filename = "plots/1.4.4Average_length_of_delay_duration.png")
  ggplot(data,aes(x=data$CRS_ELAPSED_TIME,y=data$AVE_DELAY_DURATION))+
    geom_point()+geom_line()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    ggtitle("Average Length of Delay-Duration") +
    xlab("Duration(min)") + ylab("Average Length of Delay(min)")+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  data$DISTANCE_GROUP=as.factor(data$DISTANCE_GROUP)
  data$AVE_DELAY_DISTANCE=ave(data$ARR_DELAY,data$DISTANCE_GROUP)
  png(filename = "plots/1.4.4Average_length_of_delay_distance_group.png")
  ggplot(data, aes(x=data$DISTANCE_GROUP,
                   y=data$AVE_DELAY_DISTANCE, 
                   group=1))+geom_line()+geom_point()+
    ggtitle("Average Length of Delay-Distance Group")+
    xlab("Distance Group")+ylab("Average Length of Delay(min)")+ 
    scale_x_discrete(labels = c("Less Than 250 Miles", "250-499 Miles", 
                                "500-749 Miles", "750-999 Miles", 
                                "1000-1249 Miles", "1250-1499 Miles", 
                                "1500-1749 Miles", "1750-1999 Miles", 
                                "2000-2249 Miles", "2250-2499 Miles", 
                                "2500 Miles and Greater"))+
    theme(plot.title = element_text(hjust = 0.5))+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  dev.off()
  
  #2. Proportion of Flights Delayed per feature
  #data <- data.list[["train"]]
  #source("scripts/loadLibraries.R")
  #load("data/traindf_data_for_analysis.RData")
  delayedFlights <- data[(data$ARR_DEL15 == "1"),]
  
  #2.1 Carrier
  numOfDelayedFlights <- count(delayedFlights, CARRIER)
  numOfFLights        <- count(data,           CARRIER)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.1proportion_CARRIER.png")
  ggplot(numOfFLights,aes(x=reorder(numOfFLights$CARRIER,-proportionOfDelayedFlights), 
                          y=proportionOfDelayedFlights,
                          group=1))+
    ggtitle("Proportion of Flights Delayed per Carrier")+
    xlab("Carrier")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #2.2 State
  numOfDelayedFlights <- count(delayedFlights, ORIGIN_AIRPORT_STATE_NAME)
  numOfFLights        <- count(data,           ORIGIN_AIRPORT_STATE_NAME)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.2proportion_ORIGIN_AIRPORT_STATE_NAME.png")
  ggplot(numOfFLights,aes(x=reorder(numOfFLights$ORIGIN_AIRPORT_STATE_NAME,
                                    -proportionOfDelayedFlights),
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed in Origin States")+
    xlab("Origin State")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))+ 
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  dev.off()
  
  numOfDelayedFlights <- count(delayedFlights, DEST_AIRPORT_STATE_NAME)
  numOfFLights        <- count(data,           DEST_AIRPORT_STATE_NAME)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.2proportion_DEST_AIRPORT_STATE_NAME.png")
  ggplot(numOfFLights,aes(x=reorder(numOfFLights$DEST_AIRPORT_STATE_NAME,
                                    -proportionOfDelayedFlights),
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed in Destination States")+
    xlab("Destination State")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))+ 
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  dev.off()
  
  #2.3 Month
  numOfDelayedFlights <- count(delayedFlights, MONTH)
  numOfFLights        <- count(data,           MONTH)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.3proportion_MONTH.png")
  ggplot(numOfFLights,aes(x=numOfFLights$MONTH,
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed in Month")+
    xlab("Month")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #2.4 day of week
  numOfDelayedFlights <- count(delayedFlights, DAY_OF_WEEK)
  numOfFLights        <- count(data,           DAY_OF_WEEK)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.4proportion_DAY_OF_WEEK.png")
  ggplot(numOfFLights,aes(x=numOfFLights$DAY_OF_WEEK,
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed each Day of Week")+
    xlab("Weekdays")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))
  dev.off()
  
  #2.5 Hour of day (hour bin)
  numOfDelayedFlights <- count(delayedFlights, DEP_TIME_BINS)
  numOfFLights        <- count(data,           DEP_TIME_BINS)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.5proportion_DEP_TIME_BINS.png")
  ggplot(numOfFLights,aes(x=numOfFLights$DEP_TIME_BINS,
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed across Departure Hour")+
    xlab("Departure Hour")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))+ 
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  dev.off()
  
  numOfDelayedFlights <- count(delayedFlights, ARR_TIME_BINS)
  numOfFLights        <- count(data,           ARR_TIME_BINS)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.5proportion_ARR_TIME_BINS.png")
  ggplot(numOfFLights,aes(x=numOfFLights$ARR_TIME_BINS,
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed across Arrival Hour")+
    xlab("Arrival Hour")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))+ 
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  dev.off()
  
  #2.6 Duration/Distance
  numOfDelayedFlights <- count(delayedFlights, DISTANCE_GROUP)
  numOfFLights        <- count(data,           DISTANCE_GROUP)
  proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
  png(filename = "plots/2.6proportion_Distance_group.png")
  ggplot(numOfFLights,aes(x=numOfFLights$DISTANCE_GROUP,
                          y=proportionOfDelayedFlights,group=1))+
    ggtitle("Proportion of Flights Delayed across Distance Groups")+
    xlab("Distance Groups")+ylab("Proportion of Flights Delayed")+
    geom_point()+geom_line()+
    theme(plot.title = element_text(hjust = 0.5))+ 
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    scale_x_discrete(labels = c("Less Than 250 Miles", "250-499 Miles", 
                                "500-749 Miles", "750-999 Miles", 
                                "1000-1249 Miles", "1250-1499 Miles", 
                                "1500-1749 Miles", "1750-1999 Miles", 
                                "2000-2249 Miles", "2250-2499 Miles", 
                                "2500 Miles and Greater"))
  dev.off()
  
  
  "#Graveyard
  #2. Number of delayed flights per feature
  #2.1 Carrier
  #delayedFlights <- subset(data, data$ARR_DELAY > 0)
  NUM_OF_DELAY_CARRIER=count(delayedFlights,CARRIER)
  plot(x=NUM_OF_DELAY_CARRIER$CARRIER,NUM_OF_DELAY_CARRIER$n,
  main="Number of Delayed Flights per Carrier",
  xlab="Carrier",ylab="Number of Delayed Flights")
  #2.2 State
  NUM_OF_DELAY_ORIGIN_STATE=count(delayedFlights,ORIGIN_AIRPORT_STATE_NAME)
  plot(x=NUM_OF_DELAY_ORIGIN_STATE$ORIGIN_AIRPORT_STATE_NAME,NUM_OF_DELAY_ORIGIN_STATE$n,
  main="Number of Delayed Flights per Origin State",
  xlab="",ylab="Number of Delayed Flights",
  las=2)
  
  NUM_OF_DELAY_DEST_STATE=count(delayedFlights,DEST_AIRPORT_STATE_NAME)
  plot(x=NUM_OF_DELAY_DEST_STATE$DEST_AIRPORT_STATE_NAME,NUM_OF_DELAY_DEST_STATE$n,
  main="Number of Delayed Flights per Destination State",
  xlab="",ylab="Number of Delayed Flights",
  las=2)
  #2.3 Month
  NUM_OF_DELAY_MONTH=count(delayedFlights,MONTH)
  plot(x=NUM_OF_DELAY_MONTH$MONTH,NUM_OF_DELAY_MONTH$n,
  main="Number of Delayed Flights per Month",
  xlab="Month",ylab="Number of Delayed Flights")
  #2.4 Weekday
  NUM_OF_DELAY_WEEKDAY=count(delayedFlights,DAY_OF_WEEK)
  plot(x=NUM_OF_DELAY_WEEKDAY$DAY_OF_WEEK,NUM_OF_DELAY_WEEKDAY$n,
  main="Number of Delayed Flights per Weekday",
  xlab="Weekday",ylab="Number of Delayed Flights")
  #2.5 Hour of day(hour bin)
  NUM_OF_DELAY_DEP_HOUR=count(delayedFlights,DEP_TIME_BINS)
  par(mar=c(5.8,2,2,2))
  plot(x=NUM_OF_DELAY_DEP_HOUR$DEP_TIME_BINS,NUM_OF_DELAY_DEP_HOUR$n,
  main="Number of Delayed Flights per Departure Hour",
  xlab="",ylab="Number of Delayed Flights",
  las=2)
  
  NUM_OF_DELAY_ARR_HOUR=count(delayedFlights,ARR_TIME_BINS)
  plot(x=NUM_OF_DELAY_ARR_HOUR$ARR_TIME_BINS,NUM_OF_DELAY_ARR_HOUR$n,
  main="Number of Delayed Flights per Arrival Hour",
  xlab="",ylab="Number of Delayed Flights",
  las=2)
  #2.6 Duration/Distance
  par(mar=c(5.8,5,2,2))
  NUM_OF_DELAY_DURATION=count(delayedFlights,round(CRS_ELAPSED_TIME,digits = -1))
  plot(x=NUM_OF_DELAY_DURATION$`round(CRS_ELAPSED_TIME, digits = -1)`,NUM_OF_DELAY_DURATION$n,
  main="Number of Delayed Flights per Duration",
  xlab="Duration",ylab="Number of Delayed Flights")
  -"
  
  #delayedFlights <- subset(clean.data, ARR_DELAY > 0) 
  #boxplot(delayedFlights$ARR_DELAY~delayedFlights$DAY_OF_WEEK,data=delayedFlights,
  #       main="Length of Delay each Weekday", 
  #        xlab="Weekday",
  #        ylab="Length of Delay",
  #        outline = F)#delete, cuz results not as significant as 1.4.2
  #boxplot(delayedFlights$CRS_DEP_TIME~delayedFlights$DELAY_GROUPS,data=delayedFlights,
  #        main="Delay group and departure time", 
  #        xlab="Delay Group",
  #        ylab="Departure Time",
  #        outline = F)#delete, cuz results not as significant as 1.4.3
  #boxplot(delayedFlights$ARR_DELAY~delayedFlights$MONTH,data = delayedFlights,
  #        main="Arrival Delay in 12 months", 
  #        xlab="Month",
  #        ylab="Arrival Delay",
  #        outline = F)#delete, cuz results not as significant as 1.4.1
  #boxplot(delayedFlights$ARR_DELAY~delayedFlights$CARRIER,data=delayedFlights,
  #        main="Arrival delay per carrier", 
  #        xlab="Carrier",
  #        ylab="Arrival delay",
  #        outline = F)#keep, cuz it shows some significant results
  #delayedFlights$DISTANCE_group <- cut(delayedFlights$DISTANCE, 
  #                                     breaks = c(-Inf, 250, 500, 750, 1000, 1250, 1500, 1750, 2000, Inf),
  #                                     labels = c("less than 250",
  #                                                "250-500",
  #                                                "500-750",
  #                                                "750-1000",
  #                                                "1000-1250",
  #                                                "1250-1500",
  #                                                "1500-1750",
  #                                                "1750-2000",
  #                                                "more than 2000"), 
  #                                     right = FALSE)
  #boxplot(delayedFlights$ARR_DELAY~delayedFlights$DISTANCE_group,
  #        main="Arrival delay vs. Distance",
  #        xlab = "Distance group", ylab = "Arrival delay",
  #        outline = F)#delete, cuz results not as significant as 1.4.4