analyzeCausesOfDelay <- function(data) {
  d <- data
  delayedFlightsWithKnownReason <- subset(d,
                                          d$CARRIER_DELAY > 0 |
                                          d$NAS_DELAY > 0 |
                                          d$WEATHER_DELAY > 0 |
                                          d$SECURITY_DELAY > 0 |
                                          d$LATE_AIRCRAFT_DELAY > 0)
  
  totalNumDelayedFlights <- as.numeric((count(d, ARR_DEL15))[2,2])
  numDelayedFlightsWithReason <- as.numeric(count(delayedFlightsWithKnownReason, ARR_DEL15)[1,2])
  numDelayedFlightsWithUnknownReason <- totalNumDelayedFlights - numDelayedFlightsWithReason
  
  delayReason1 <- na.omit(d$CARRIER_DELAY[d$CARRIER_DELAY>0])
  delayReason2 <- na.omit(d$NAS_DELAY[d$NAS_DELAY>0])
  delayReason3 <- na.omit(d$WEATHER_DELAY[d$WEATHER_DELAY>0])
  delayReason4 <- na.omit(d$SECURITY_DELAY[d$SECURITY_DELAY>0])
  delayReason5 <- na.omit(d$LATE_AIRCRAFT_DELAY[d$LATE_AIRCRAFT_DELAY>0])
  
  numReason1 <- length(delayReason1)
  numReason2 <- length(delayReason2)
  numReason3 <- length(delayReason3)
  numReason4 <- length(delayReason4)
  numReason5 <- length(delayReason5)
  
  percReason1 <- numReason1/totalNumDelayedFlights*100
  percReason2 <- numReason2/totalNumDelayedFlights*100
  percReason3 <- numReason3/totalNumDelayedFlights*100
  percReason4 <- numReason4/totalNumDelayedFlights*100
  percReason5 <- numReason5/totalNumDelayedFlights*100
  percOther   <- numDelayedFlightsWithUnknownReason/totalNumDelayedFlights*100
  
  data_p <- data.frame(perc = c(percReason1,percReason2,percReason3, percReason4, percReason5),
  					 reason = factor(c("Carrier",
  		 								"National Aviation System",
  		 								"Extreme Weather",
  		 								"Security",
  		 								"Late Aircraft")), 
  					 		   levels = c(#"Reason Not Given",
  					 		   	"Carrier",
  					 		   	"National Aviation System",
  					 		   	"Extreme Weather",
  					 		   	"Security",
  					 		   	"Late Aircraft"))
  
  par(mai = c(1,2.3,0.5,0.5))
  g <- ggplot(data_p, aes(x=reason, y=perc, fill=reason, color=reason, alpha=0.9)) + geom_bar(stat="identity", width=0.5) +
  	geom_text(label=round(data_p$perc, digits=2), hjust=0.5, vjust=-0.75, color="black", size=4) + 
  	coord_flip() + 
  	labs(x = "Reasons for Delay", y= "Percentage [%]") +
  	# theme_bw()+
  	theme_light()+
  	theme(plot.title = element_text(size=18, face="bold", vjust=3)) +
  	theme(
  		axis.text=element_text(size=12),
  		axis.title.x = element_text(color="black", size=13, face="bold", vjust=-0.35),
  		axis.title.y = element_text(color="black", size=13,face="bold", vjust=0.35)
  	) +
  	theme(legend.position="none") +
  	ggtitle("Proportion of Flights with reason of delay") +
  	coord_fixed(ratio = 0.06)
  g
  # par(mai = c(1,2.3,0.5,0.5))
  # barplot(c(#numDelayedFlightsWithUnknownReason,
  #           percReason1,
  #           percReason2,
  #           percReason3,
  #           percReason4,
  #           percReason5),
  #         horiz = TRUE,
  #         las = 1,
  #         main = "Reasons for Flight Delays",
  #         xlab = "Percentage of Delayed Flights",
  #         names.arg = c(#"Reason Not Given",
  #                       "Carrier",
  #                       "National Aviation System",
  #                       "Extreme Weather",
  #                       "Security",
  #                       "Late Aircraft"),
  #         cex.names = 1.0,
  # 		col=colours
  # )
  # xlab = c(0,100000, 200000, 300000, 400000, 500000)
  # axis(1, at=xlab, labels=xlab)
  
  # par(mai = c(0.5,0.5,0.5,0.5))
  # hist(delayReason1, breaks = 1000, xlim = c(-60,240), main="Carrier Delay")
  # hist(delayReason2, breaks = 1000, xlim = c(-10,60),  main="NAS Delay")
  # hist(delayReason3, breaks = 1000, xlim = c(-60,240), main="Weather Delay")
  # hist(delayReason4, breaks = 100,  xlim = c(-60,240), main="Security Delay")
  # hist(delayReason5, breaks = 500,  xlim = c(-60,240), main="Late Aircraft Delay")
  # 
  # hist(d$ARR_DELAY,
  #      breaks = 2000,
  #      xlim = c(-45,90),
  #      main="Arrival Delay",
  #      xlab="Arrival Delay in Minutes",
  #      ylab="Flights",
  #      col="gray")
  # xlablevels = c(-45,0,15,30,60,90)
  # axis(1, at=xlab, labels=xlablevels)
}