toMinutesAfterMidnight <- function(time2400) {
  time2400 <- as.numeric(time2400)
  minutesAfterHour <- time2400 %% 100
  hour <- floor(time2400/100)
  minutesInDayAfterMidnight <- (60*hour + minutesAfterHour)
  return(minutesInDayAfterMidnight)
}

# toMinutesAfterMidnight(0130) # 90
# toMinutesAfterMidnight(0000) # 0
# toMinutesAfterMidnight(1200) # 720
# toMinutesAfterMidnight(2359) # 1439

toMinutesAfterMidnightSquared <- function(time2400) {
  time2400 <- as.numeric(time2400)
  minutesAfterHour <- time2400 %% 100
  hour <- floor(time2400/100)
  minutesInDayAfterMidnight <- (60*hour + minutesAfterHour)
  return(minutesInDayAfterMidnight*minutesInDayAfterMidnight)
}

# toMinutesAfterMidnightSquared(0130) # 8100

