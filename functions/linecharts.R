data=dataForAnalysisOfCausesOfDelay

#1.1 Carrier
data$AVE_DELAY_CARRIER=ave(data$ARR_DELAY,data$CARRIER)

g <- ggplot(data,aes(x=reorder(data$CARRIER,-data$AVE_DELAY_CARRIER),
					 y=data$AVE_DELAY_CARRIER,
					 group = 1))+
	geom_text(label=round(data$AVE_DELAY_CARRIER, digits=2), hjust=0.5, vjust=-0.75, color="black", size=4)+
	geom_line() +
	geom_point()+
	theme_light()+
	ggtitle("Average Length of Delay per Carrier") +
	xlab("Carrier") + ylab("Average Length of Delay(min)")+
	theme(plot.title = element_text(size=18, face="bold", vjust=3),
		  axis.text=element_text(size=12),
		  axis.title.x = element_text(color="black", size=13, face="bold", vjust=-0.35),
		  axis.title.y = element_text(color="black", size=13,face="bold", vjust=0.35))
g

#2. Proportion of Flights Delayed per feature
#data <- data.list[["train"]]
#source("scripts/loadLibraries.R")
#load("data/traindf_data_for_analysis.RData")
delayedFlights <- data[(data$ARR_DEL15 == "1"),]

#2.1 Carrier
numOfDelayedFlights <- count(delayedFlights, CARRIER)
numOfFLights        <- count(data,           CARRIER)
proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
# png(filename = "plots/2.1proportion_CARRIER.png")
g <- ggplot(numOfFLights,aes(x=reorder(numOfFLights$CARRIER,-proportionOfDelayedFlights), 
						y=proportionOfDelayedFlights, col=proportionOfDelayedFlights,
						group=1))+
	geom_text(label=round(proportionOfDelayedFlights, digits=2), hjust=0.5, vjust=-0.75, color="black", size=4)+
	ggtitle("Proportion of Flights Delayed per Carrier")+
	xlab("Carrier")+ylab("Proportion of Flights Delayed")+
	geom_point()+geom_line()+theme(legend.position="none") +
	theme(plot.title = element_text(size=18, face="bold", vjust=3),
		  axis.text=element_text(size=12),
		  axis.title.x = element_text(color="black", size=13, face="bold", vjust=-0.35),
		  axis.title.y = element_text(color="black", size=13,face="bold", vjust=0.35))
g

# Proportion of flights delayed per month
numOfDelayedFlights <- count(delayedFlights, MONTH)
numOfFLights        <- count(data,           MONTH)
proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
# png(filename = "plots/2.3proportion_MONTH.png")
g <- ggplot(numOfFLights,aes(x=numOfFLights$MONTH,
						y=proportionOfDelayedFlights,col=proportionOfDelayedFlights, group=1))+
	geom_text(label=round(proportionOfDelayedFlights, digits=2), hjust=0.5, vjust=-0.75, color="black", size=4)+
	ggtitle("Proportion of Flights Delayed in Month")+
	xlab("Month")+ylab("Proportion of Flights Delayed")+
	geom_point()+geom_line()+theme(legend.position="none") +
	theme(plot.title = element_text(size=18, face="bold", vjust=3),
		  axis.text=element_text(size=12),
		  axis.title.x = element_text(color="black", size=13, face="bold", vjust=-0.35),
		  axis.title.y = element_text(color="black", size=13,face="bold", vjust=0.35))

g

#2.4 day of week
numOfDelayedFlights <- count(delayedFlights, DAY_OF_WEEK)
numOfFLights        <- count(data,           DAY_OF_WEEK)
proportionOfDelayedFlights <- (numOfDelayedFlights$n/numOfFLights$n)
# png(filename = "plots/2.4proportion_DAY_OF_WEEK.png")
g <- ggplot(numOfFLights,aes(x=numOfFLights$DAY_OF_WEEK,
						y=proportionOfDelayedFlights,fill=numOfFLights$DAY_OF_WEEK, 
						col=numOfFLights$DAY_OF_WEEK))+
	geom_bar(stat="identity", width=0.5) +
	ggtitle("Proportion of Flights Delayed each Day of Week")+
	xlab("Weekdays")+ylab("Proportion of Flights Delayed")+
	geom_point()+geom_line()+theme(legend.position="none") +
	theme(plot.title = element_text(hjust = 0.5))
g
