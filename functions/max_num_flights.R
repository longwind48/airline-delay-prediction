# 12.1 max_num_flights function
# -> max_num_flights is a function for the delay prediction function to use for calculating the number of 
#    flights in the database for a given city.
# -> Inputs: list of codes retrived in the delay_prediction function
# -> Output: The code with the largest number of flights.
max_num_flights <- function(codes, data) {
  # Array to store all airport codes
  num_store <- list()
  
  if (length(codes)<1) {
    print('Try entering your city/airport again. No matching airports found.')
    return
  }
  for (i in 1:length(codes)) {
    num_flights <- sum(grepl(codes[i],data$ORIGIN_AIRPORT_ID))
    num_store[i] <- num_flights  
  }
  # Now find the maximum row  
  max_num_store <- max(unlist(num_store))
  max_ind = match(max_num_store, num_store)
  # Now we know which code had the most flights. Return it.
  return(codes[max_ind])
}
# codes <- c(13930, 11298)
# codes1 <- c(11703,12478, 12541, 12545, 12546, 12548, 12953, 13784, 15346, 15859)
# max_num_flights(codes1, dataset)
